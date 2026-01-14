extends Node

var stage = 'intro'
var inventory = {'binoculars': 0, 'axe': 0, 'bottle': 0}
var score = 0

var usingBinoculars = false
var playerSleeping = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
