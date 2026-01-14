extends CharacterBody3D

@onready var LookAround = $LookAround
@onready var raycast = $LookAround/RayCast3D
@onready var bottle = preload("res://bottle.tscn")

var movement_speed = 380
var base_movement_speed = 380
var fall_speed = -50  # negative
var mouse_rotation_hor = 0
var mouse_rotation_vert = 0
var mouse_sensitivity = 0.01  # sensitivity of rotating the camera
var player_angle = 0  # what direction is the player looking
var movement_direciton = {'w':0, 'a':0, 's':0, 'd':0}

var stamina = 1000
var timeSleeping = 0

func _ready() -> void:
	$CanvasLayer/ScreenFade.visible = true

func _physics_process(delta: float) -> void:
	player_angle = LookAround.rotation.y
	#print(stamina)
	
	WASD_key_pressed("move_forward", "w")
	WASD_key_pressed("move_backward", "s")
	WASD_key_pressed("move_left", "a")
	WASD_key_pressed("move_right", "d")
	
	var move_player_XZ = Vector2(movement_direciton['w'] - movement_direciton['s'], movement_direciton['d'] - movement_direciton['a'])
	if move_player_XZ.length() > 1.0:
		move_player_XZ = move_player_XZ.normalized()
	
	velocity.x = (-sin(player_angle) * move_player_XZ.x + sin(player_angle + PI/2) * move_player_XZ.y) * delta * movement_speed
	velocity.z = (-cos(player_angle) * move_player_XZ.x + cos(player_angle + PI/2) * move_player_XZ.y) * delta * movement_speed
	
	if is_on_floor() and not Global.playerSleeping:
		velocity.y = 0
	else:
		velocity.y += fall_speed * delta
	
	# NOTE: press ESC to show cursor (e.g. in order to enable full screen), then click in-game again to hide cursor
	if Input.is_action_just_pressed("Escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("click_l"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_pressed("shift"):
		if stamina > 0:
			movement_speed = base_movement_speed * (1 + stamina / 1000.0 / 1.6)
			if movement_direciton['w'] != 0 or movement_direciton['a'] != 0 or movement_direciton['s'] != 0 or movement_direciton['d'] != 0:
				stamina -= 1
	else:
		movement_speed = base_movement_speed
	
	if Input.is_action_just_pressed("interact"):
		if raycast.is_colliding():
			var target = raycast.get_collider()
			if target.is_in_group("door"):
				if target.is_open:
					target.close()
				else:
					target.open()
			elif target.is_in_group("locker"):
				if target.is_open:
					target.close()
				else:
					target.open()
			elif target.is_in_group("bed"):
				position = Vector3(-6.906, 6.889, -24.53)
				rotation_degrees = Vector3(80.0, 180.0, 0.0)
				Global.playerSleeping = true
				LookAround.rotation_degrees = Vector3(0.0, 0.0, 0.0)
			elif target.is_in_group("binoculars"):
				Global.inventory['binoculars'] = 1
				target.queue_free()
			elif target.is_in_group("bottles"):
				if Global.inventory['bottle'] == 0:
					Global.inventory['bottle'] = 1
					print("you picked up a bottle")
	
	if Global.playerSleeping and Input.is_action_just_pressed("shift"):
		position = Vector3(-3.312, 5.737, -25.41)
		Global.playerSleeping = false
		rotation_degrees = Vector3(0.0, 0.0, 0.0)
	
	if Global.playerSleeping:
		timeSleeping += delta
	else:
		timeSleeping = 0
	
	if timeSleeping > 4.0:
		stamina += 1
	
	stamina = clamp(stamina, 0, 1000)
	
	$CanvasLayer/StaminaFrame/StaminaBar.scale.x = stamina / 1000.0
	
	if not Global.usingBinoculars:
		if Input.is_action_just_pressed("click_r"):
			if Global.inventory['binoculars'] == 1:
				Global.usingBinoculars = true
	else:
		if Input.is_action_just_pressed("click_r"):
			Global.usingBinoculars = false
	
	if Input.is_action_just_pressed("click_l"):
		if Global.inventory['bottle'] == 1:
			Global.inventory['bottle'] = 0
			throw_bottle()
	
	$CanvasLayer/BinocularsView.visible = Global.usingBinoculars
	$CanvasLayer/Pointer.visible = not Global.usingBinoculars
	if Global.usingBinoculars:
		if $LookAround/Camera3D.fov > 10:
			$LookAround/Camera3D.fov -= 5
	else:
		if $LookAround/Camera3D.fov < 75:
			$LookAround/Camera3D.fov += 5
	
	if Global.stage == 'intro' and $CanvasLayer/ScreenFade.self_modulate.a > 0:
		$CanvasLayer/ScreenFade.self_modulate.a -= 0.01
	
	move_and_slide()

# Allow the player to look around when moving the mouse
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not Global.usingBinoculars and not Global.playerSleeping:
			mouse_rotation_hor -= event.relative.x * mouse_sensitivity
			LookAround.rotation.y = mouse_rotation_hor
			mouse_rotation_vert = clamp(mouse_rotation_vert - event.relative.y * mouse_sensitivity, deg_to_rad(-80), deg_to_rad(90))
			LookAround.rotation.x = mouse_rotation_vert

# Use this method to achieve smooth movement
func WASD_key_pressed(action, direction):
	if Input.is_action_pressed(action) and not Global.usingBinoculars and not Global.playerSleeping:
		if movement_direciton[direction] < 1.0:
			movement_direciton[direction] += 0.1
	elif movement_direciton[direction] > 0.0:
		movement_direciton[direction] -= 0.1
	if movement_direciton[direction] < 0:
		movement_direciton[direction] = 0

func throw_bottle():
	var new_bottle = bottle.instantiate()
	get_tree().current_scene.add_child(new_bottle)
	new_bottle.global_position = LookAround.global_position
	new_bottle.apply_impulse(-LookAround.global_basis.z * 25.0)
	new_bottle.apply_torque_impulse(Vector3(randf_range(-10.0, 10.0), 0.0, randf_range(-10.0, 10.0)))
	
