extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var ik: SkeletonIK3D = $Armature/Skeleton3D/TentacleIK
@onready var target: Node3D = $IKTarget

func _ready():
	#randomize()
	#anim.speed_scale = randf_range(0.25, 0.65)
	#anim.play("Action")
	ik.start()
	var target_pos = Vector3(0, -20.0, -20.0)
	target.global_position += target_pos
	target.look_at(target_pos, Vector3.FORWARD)
