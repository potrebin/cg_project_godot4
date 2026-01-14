extends ColorRect

var distortion_multiplier = 1.0

func _process(delta: float) -> void:
	distortion_multiplier = 0.0 if Global.usingBinoculars else 1.0
	material.set_shader_parameter("strength", Global.distortion_scale * distortion_multiplier)
	material.set_shader_parameter("color_amount", Global.distortion_scale * 10.0 * distortion_multiplier)
