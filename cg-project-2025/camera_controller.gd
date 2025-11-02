extends Camera3D

# Simple fly camera controller
# Hold right mouse button and use WASD to fly around
# Scroll wheel to change speed

"""
@export var move_speed := 20.0
@export var look_sensitivity := 0.003
@export var speed_scale := 1.0

var is_rotating := false

func _ready():
	# Don't capture mouse by default, only when right-clicking
	pass

func _input(event):
	# Mouse look - only when right mouse button is held
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_rotating = event.pressed
			if is_rotating:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Mouse movement for camera rotation
	if event is InputEventMouseMotion and is_rotating:
		rotate_y(-event.relative.x * look_sensitivity)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * look_sensitivity)

		# Clamp vertical rotation to prevent flipping
		rotation.x = clamp(rotation.x, -PI/2, PI/2)

	# Mouse wheel for speed adjustment
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			speed_scale = min(speed_scale * 1.2, 10.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			speed_scale = max(speed_scale / 1.2, 0.1)

func _process(delta):
	if not is_rotating:
		return

	# WASD movement
	var input_dir := Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		input_dir -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		input_dir += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		input_dir -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		input_dir += transform.basis.x
	if Input.is_key_pressed(KEY_Q):
		input_dir -= transform.basis.y
	if Input.is_key_pressed(KEY_E):
		input_dir += transform.basis.y

	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		position += input_dir * move_speed * speed_scale * delta

"""
