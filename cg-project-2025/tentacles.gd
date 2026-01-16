extends Node3D
class_name Tentacle

signal grabbed(point: GrabPoint)
signal released(point: GrabPoint)
signal despawned()

enum State { INACTIVE, EMERGE, REACH, HOLD, RETURN }

@export var emerge_depth: float = 20          # full "exit length" from the water
@export var emerge_time: float = 6.0           # was 1.0 → now 2 seconds
@export var emerge_min_ratio: float = 0.2      # 20%
@export var emerge_max_ratio: float = 0.6      # 60%
@export var reach_time: float = 4.0
@export var return_time: float = 4.0
@export var grab_distance: float = 0.25    # distance at which we "consider it grabbed"

@onready var ik_target: Node3D = $IKTarget
@onready var ik: SkeletonIK3D = $Armature/Skeleton3D/TentacleIK
@onready var anim: AnimationPlayer = $"AnimationPlayer" # if present
@onready var pole: Node3D = $IKPole

var manager: Node = null
var spawn_point: TentacleSpawnPoint = null
var target_point: GrabPoint = null
var ship_center: Node3D = null

var state: State = State.INACTIVE
var _water_pos: Vector3
var _surface_pos: Vector3

var hp = 3

func _ready():
	ik.override_tip_basis = false
	ik.use_magnet = true
	ik.start()
	
func _process(_delta):
	if ik.use_magnet:
		ik.magnet = pole.global_position


func activate(from_spawn: TentacleSpawnPoint, to_point: GrabPoint) -> void:
	spawn_point = from_spawn
	target_point = to_point

	_surface_pos = spawn_point.global_position
	_water_pos = _surface_pos - Vector3.UP * emerge_depth

	# appear underwater
	global_position = _water_pos

	# IKTarget starts near the tip / along the tentacle — you can just set it to self
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
		# no target — go back
		begin_return()
		return

	# Move IKTarget to the grab point
	var tw = create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(ik_target, "global_position", target_point.global_position, reach_time)
	tw.finished.connect(_on_reach_finished)

func _on_reach_finished():
	if state != State.REACH:
		return

	# Check that we are close enough (can be made more precise via tip BoneAttachment)
	var tip_pos = ik_target.global_position
	var d = tip_pos.distance_to(target_point.global_position)

	if d <= grab_distance:
		state = State.HOLD
		# lock IKTarget exactly on the point (ship is static)
		ik_target.global_position = target_point.global_position

		target_point.occupy(self)
		emit_signal("grabbed", target_point)

	else:
		# didn't reach — return
		begin_return()
	
	Global.show_distortions = 1.0

func begin_return():
	if state == State.RETURN:
		return

	# Release the point if there was one
	if target_point:
		target_point.release(self)
		emit_signal("released", target_point)

	state = State.RETURN

	var tw = create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "global_position", _water_pos, return_time)
	tw.finished.connect(_on_return_finished)

func _on_return_finished():
	# notify manager that the spawn was freed
	emit_signal("despawned")
	queue_free()

# This is for the future: an axe/bottle hit will call this
func take_hit(damage):
	hp -= damage
	if hp <= 0:
		begin_return()
		Global.score += 1
	
