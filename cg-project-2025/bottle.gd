extends RigidBody3D

@onready var particles = preload("res://bottle_particles.tscn")

func _physics_process(delta: float) -> void:
	if position.y < 4.5:
		destroy()

func destroy():
	var new_particles = particles.instantiate()
	get_tree().current_scene.add_child(new_particles)
	new_particles.position = global_position
	new_particles.emitting = true
	queue_free()
