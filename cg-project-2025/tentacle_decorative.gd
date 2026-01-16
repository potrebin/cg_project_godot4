extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	anim.play("Action", -1, randf_range(0.6, 1))
