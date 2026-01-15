extends Node3D
class_name Tentacle

signal grabbed(point: GrabPoint)
signal released(point: GrabPoint)
signal despawned()

enum State { INACTIVE, EMERGE, REACH, HOLD, RETURN }

@export var emerge_depth: float = 20          # полная "длина выхода" из воды
@export var emerge_time: float = 6.0           # было 1.0 → теперь 2 секунды
@export var emerge_min_ratio: float = 0.2      # 20%
@export var emerge_max_ratio: float = 0.6      # 60%
@export var reach_time: float = 4.0
@export var return_time: float = 4.0
@export var grab_distance: float = 0.25    # дистанция для "считаем, что схватила"

@onready var ik_target: Node3D = $IKTarget
@onready var ik: SkeletonIK3D = $Armature/Skeleton3D/TentacleIK
@onready var anim: AnimationPlayer = $"AnimationPlayer" # если есть
@onready var pole: Node3D = $IKPole

var manager: Node = null
var spawn_point: TentacleSpawnPoint = null
var target_point: GrabPoint = null
var ship_center: Node3D = null

var state: State = State.INACTIVE
var _water_pos: Vector3
var _surface_pos: Vector3

func _ready():
	ik.override_tip_basis = false
	ik.use_magnet = true
	ik.start()
	
func _process(_delta):
	if ik.use_magnet:
		ik.magnet = pole.global_position

	# Ориентация кончика через IKTarget
	if state == State.REACH or state == State.HOLD:
		_update_target_rotation_to_ship()

func activate(from_spawn: TentacleSpawnPoint, to_point: GrabPoint) -> void:
	spawn_point = from_spawn
	target_point = to_point

	_surface_pos = spawn_point.global_position
	_water_pos = _surface_pos - Vector3.UP * emerge_depth

	# появляемся под водой
	global_position = _water_pos

	# IKTarget сначала рядом с кончиком/вдоль тентакли — можно просто поставить на себя
	ik_target.global_position = global_position
	
	var ratio := randf_range(emerge_min_ratio, emerge_max_ratio)
	var emerge_end_pos: Vector3 = _water_pos.lerp(_surface_pos, ratio)

	state = State.EMERGE
	
	state = State.EMERGE

	var tw = create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "global_position", emerge_end_pos, emerge_time)
	tw.finished.connect(_on_emerge_finished)

func _on_emerge_finished():
	if state != State.EMERGE:
		return
		
	_begin_reach()

func _begin_reach():
	state = State.REACH

	if target_point == null:
		# нет цели — уходим обратно
		begin_return()
		return

	# Двигаем IKTarget к точке захвата
	var tw = create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(ik_target, "global_position", target_point.global_position, reach_time)
	tw.finished.connect(_on_reach_finished)

func _on_reach_finished():
	if state != State.REACH:
		return

	# Проверка, что мы достаточно близко (можно сделать точнее через BoneAttachment кончика)
	var tip_pos = ik_target.global_position
	var d = tip_pos.distance_to(target_point.global_position)

	if d <= grab_distance:
		state = State.HOLD
		# фиксируем IKTarget ровно на точке (корабль статичен)
		ik_target.global_position = target_point.global_position

		target_point.occupy(self)
		emit_signal("grabbed", target_point)

	else:
		# не дотянулись — возвращаемся
		begin_return()

func begin_return():
	if state == State.RETURN:
		return

	# Освобождаем точку, если была
	if target_point:
		target_point.release(self)
		emit_signal("released", target_point)

	state = State.RETURN

	var tw = create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "global_position", _water_pos, return_time)
	tw.finished.connect(_on_return_finished)

func _on_return_finished():
	# сообщаем менеджеру, что спавн освободился
	emit_signal("despawned")
	queue_free()

# Это на будущее: удар топором/бутылкой будет вызывать это
func take_hit():
	# Только в HOLD имеет смысл, но можно разрешить всегда
	begin_return()
	
func _update_target_rotation_to_ship():
	if ship_center == null:
		return

	# хотим, чтобы "вперёд" IKTarget смотрело на центр корабля
	var center_pos = ship_center.global_position
	ik_target.look_at(center_pos, Vector3.UP)
	ik_target.rotate_object_local(Vector3.UP, deg_to_rad(-270)) # пример
