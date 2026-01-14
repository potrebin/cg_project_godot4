extends RigidBody3D

@onready var particles = preload("res://bottle_particles.tscn")

func _physics_process(delta: float) -> void:
	if position.y < -10:
		queue_free()

func destroy():
	var new_particles = particles.instantiate()
	get_tree().current_scene.add_child(new_particles)
	new_particles.position = global_position
	new_particles.emitting = true
	queue_free()


func _on_bottle_area_3d_area_entered(area: Area3D) -> void:
	destroy()


func _on_bottle_area_3d_body_entered(body: Node3D) -> void:
	destroy()
