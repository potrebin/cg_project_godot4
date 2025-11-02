extends CharacterBody3D

@onready var LookAround = $LookAround

var movement_speed = 380
var fall_speed = -50  # negative
var mouse_rotation_hor = 0
var mouse_rotation_vert = 0
var mouse_sensitivity = 0.01  # sensitivity of rotating the camera
var player_angle = 0  # what direction is the player looking
var movement_direciton = {'w':0, 'a':0, 's':0, 'd':0}

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	player_angle = LookAround.rotation.y
	
	WASD_key_pressed("move_forward", "w")
	WASD_key_pressed("move_backward", "s")
	WASD_key_pressed("move_left", "a")
	WASD_key_pressed("move_right", "d")
	
	var move_player_XZ = Vector2(movement_direciton['w'] - movement_direciton['s'], movement_direciton['d'] - movement_direciton['a'])
	if move_player_XZ.length() > 1.0:
		move_player_XZ = move_player_XZ.normalized()
	
	velocity.x = (-sin(player_angle) * move_player_XZ.x + sin(player_angle + PI/2) * move_player_XZ.y) * delta * movement_speed
	velocity.z = (-cos(player_angle) * move_player_XZ.x + cos(player_angle + PI/2) * move_player_XZ.y) * delta * movement_speed
	
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y += fall_speed * delta
	
	# NOTE: press ESC to show cursor (e.g. in order to enable full screen), then click in-game again to hide cursor
	if Input.is_action_just_pressed("Escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("click_l"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	move_and_slide()

# Allow the player to look around when moving the mouse
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_rotation_hor -= event.relative.x * mouse_sensitivity
		LookAround.rotation.y = mouse_rotation_hor
		mouse_rotation_vert = clamp(mouse_rotation_vert - event.relative.y * mouse_sensitivity, deg_to_rad(-80), deg_to_rad(90))
		LookAround.rotation.x = mouse_rotation_vert

# Use this method to achieve smooth movement
func WASD_key_pressed(action, direction):
	if Input.is_action_pressed(action):
		if movement_direciton[direction] < 1.0:
			movement_direciton[direction] += 0.1
	elif movement_direciton[direction] > 0.0:
		movement_direciton[direction] -= 0.1
	if movement_direciton[direction] < 0:
		movement_direciton[direction] = 0
