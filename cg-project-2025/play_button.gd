extends Area2D

var hover = false

func _process(delta: float) -> void:
	if hover:
		if $Sprite2D.self_modulate.a > 0.7:
			$Sprite2D.self_modulate.a -= 0.02
		if Input.is_action_just_pressed("click_l"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().change_scene_to_file("res://game.tscn")
	else:
		if $Sprite2D.self_modulate.a < 1.0:
			$Sprite2D.self_modulate.a += 0.05
	

func _on_mouse_entered() -> void:
	hover = true

func _on_mouse_exited() -> void:
	hover = false
