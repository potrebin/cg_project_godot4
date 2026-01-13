extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	randomize()
	anim.speed_scale = randf_range(0.25, 0.65)
	anim.play("Action")
