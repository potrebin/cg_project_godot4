extends Node

@onready var bloodParticles = preload("res://monster_blood_particles.tscn")

var stage = 'intro'
var inventory = {'binoculars': 0, 'axe': 0, 'bottle': 0}
var score = 0
var has_played = false
var distortion_scale = 0.0

var usingBinoculars = false
var playerSleeping = false

var show_distortions = 0
var game_over = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if show_distortions >= 1.0 and not game_over:
		distortion_scale = sin(deg_to_rad(show_distortions)) * 0.05
		show_distortions += 0.5
		if show_distortions >= 180:
			show_distortions = 0
			distortion_scale = 0.0
	elif game_over:
		distortion_scale += 0.0005
		if distortion_scale >= 1.1:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			has_played = true
			get_tree().change_scene_to_file("res://menu.tscn")
			game_over = false
