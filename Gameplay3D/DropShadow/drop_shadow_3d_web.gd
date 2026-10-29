extends Node3D

@onready var spring_arm: SpringArm3D = %SpringArm
@onready var shadow: MeshInstance3D = %ShadowMesh

const floor_check_margin : float = 0.5

func is_above_floor() -> bool:
	return spring_arm.get_hit_length() < (spring_arm.spring_length - floor_check_margin)

func _process(delta: float) -> void:
	shadow.visible = is_above_floor()
