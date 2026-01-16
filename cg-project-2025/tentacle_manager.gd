extends Node3D
class_name TentacleManager

@export var tentacle_scene: PackedScene

@export var spawns_path: NodePath
@export var grab_points_path: NodePath

@export var spawn_interval_min: float = 7.0
@export var spawn_interval_max: float = 16.0
@export var spawn_count_min: int = 2
@export var spawn_count_max: int = 2

@export var needed_to_lose: int = 7
@export var lose_delay: float = 5.0

@export var ship_center_path: NodePath
@onready var ship_center: Node3D = get_node(ship_center_path) as Node3D

var spawns: Array[TentacleSpawnPoint] = []
var grab_points: Array[GrabPoint] = []

var lose_timer: Timer

func _ready():
	#print("TentacleManager READY")
	
	randomize()

	spawns.clear()
	for c in get_node(spawns_path).get_children():
		if c is TentacleSpawnPoint:
			spawns.append(c)
	grab_points.clear()
	for c in get_node(grab_points_path).get_children():
		if c is GrabPoint:
			grab_points.append(c)

	lose_timer = Timer.new()
	lose_timer.one_shot = true
	lose_timer.wait_time = lose_delay
	lose_timer.timeout.connect(_on_lose_timer_timeout)
	add_child(lose_timer)

	#print("Spawns found:", spawns.size())
	#print("GrabPoints found:", grab_points.size())

	_schedule_next_wave()

func _schedule_next_wave():
	var t = randf_range(spawn_interval_min, spawn_interval_max)
	var tw = create_tween()
	tw.tween_interval(t)
	tw.finished.connect(_spawn_wave)

func _spawn_wave():
	#print("spawning!")
	# 1–2 tentacles
	var want = randi_range(spawn_count_min, spawn_count_max)

	for i in range(want):
		var spawn = _pick_free_spawn()
		if spawn == null:
			break

		var point = _pick_random_of_three_nearest_free_grab(spawn.global_position)
		if point == null:
			break

		# reserve the point (so two tentacles don't choose the same one)
		var ok = point.reserve(spawn) # for now you can reserve on spawn, but better on tentacle
		# Better to reserve on the tentacle, but the tentacle isn't created yet. So:
		# 1) create the tentacle
		# 2) re-reserve on it
		if not ok:
			continue

		var tentacle: Tentacle = tentacle_scene.instantiate()
		tentacle.ship_center = ship_center
		add_child(tentacle)

		# re-reserve correctly
		point.release(spawn)
		point.reserve(tentacle)

		spawn.set_active(tentacle)
		tentacle.manager = self

		# event subscriptions
		tentacle.grabbed.connect(_on_tentacle_grabbed)
		tentacle.released.connect(_on_tentacle_released)
		tentacle.despawned.connect(_on_tentacle_despawned.bind(spawn, point, tentacle))

		tentacle.activate(spawn, point)

	# schedule the next call
	_schedule_next_wave()

func _pick_free_spawn() -> TentacleSpawnPoint:
	var candidates: Array[TentacleSpawnPoint] = []
	for s in spawns:
		if s.is_free():
			candidates.append(s)
	if candidates.is_empty():
		return null
	return candidates[randi() % candidates.size()]

func _pick_random_of_three_nearest_free_grab(from_pos: Vector3) -> GrabPoint:
	var candidates: Array = []  # we will store pairs [distance, GrabPoint]

	for p in grab_points:
		if not p.is_free():
			continue
		var better_position = p.global_position
		better_position.y = 4.0
		var d = from_pos.distance_to(better_position)
		candidates.append([d, p])

	if candidates.is_empty():
		return null

	# sort by distance
	candidates.sort_custom(func(a, b): return a[0] < b[0])

	# take top-3 (or fewer if there are few points)
	var k = min(2, candidates.size())
	var pick = candidates[randi() % k][1]
	return pick

func _on_tentacle_grabbed(_point: GrabPoint):
	_check_lose_condition()

func _on_tentacle_released(_point: GrabPoint):
	_check_lose_condition()

func _on_tentacle_despawned(spawn: TentacleSpawnPoint, point: GrabPoint, tentacle: Tentacle):
	# free the spawn and just in case the point
	spawn.clear_active(tentacle)
	if point:
		point.release(tentacle)
	_check_lose_condition()

func _count_captured() -> int:
	var c := 0
	for p in grab_points:
		if p.occupied_by != null:
			c += 1
	return c

func _check_lose_condition():
	var captured = _count_captured()
	if captured >= needed_to_lose:
		if lose_timer.is_stopped():
			#print("WARNING: %d points captured. Starting lose timer..." % captured)
			lose_timer.start()
	else:
		# if it dropped below 7 — cancel the lose timer
		if not lose_timer.is_stopped():
			#print("INFO: captured dropped to %d. Lose timer cancelled." % captured)
			lose_timer.stop()

func _on_lose_timer_timeout():
	# For now the finale is just in the console
	#print("GAME OVER: Kraken captured %d points for %0.1f seconds!" % [needed_to_lose, lose_delay])
	Global.game_over = true
