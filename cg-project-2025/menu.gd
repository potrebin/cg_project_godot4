extends Node2D

func _physics_process(delta: float) -> void:
	if Global.has_played:
		$ScoreLabel.visible = true
		$ScoreLabel.text = "YOU DIED\nScore: " + str(Global.score)
