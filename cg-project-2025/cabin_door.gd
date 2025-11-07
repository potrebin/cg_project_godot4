extends StaticBody3D

var is_open = false

func open():
	$AnimationPlayer.play("open")
	is_open = true

func close():
	$AnimationPlayer.play("close")
	is_open = false
