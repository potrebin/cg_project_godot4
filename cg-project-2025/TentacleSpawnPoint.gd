extends Marker3D

class_name TentacleSpawnPoint

var active_tentacle: Node = null

func is_free() -> bool:
	return active_tentacle == null

func set_active(t: Node) -> void:
	active_tentacle = t

func clear_active(t: Node) -> void:
	if active_tentacle == t:
		active_tentacle = null
