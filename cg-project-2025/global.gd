extends Node

var stage = 'intro'
var inventory = {'binoculars': 0}

var usingBinoculars = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
