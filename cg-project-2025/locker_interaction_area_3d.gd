extends Area3D

var is_open = false

func _process(delta: float) -> void:
	is_open = get_parent().get_parent().is_open

func open():
	get_parent().get_parent().open()
	get_parent().get_parent().is_open = true

func close():
	get_parent().get_parent().close()
	get_parent().get_parent().is_open = false
