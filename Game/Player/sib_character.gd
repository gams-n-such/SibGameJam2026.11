class_name SibCharacter
extends AnimatableBody3D


func _ready() -> void:
	Rhythm.start()


func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"move_forward"):
		try_move(Vector3.FORWARD)
	elif event.is_action_pressed(&"move_backward"):
		try_move(Vector3.BACK)
	elif event.is_action_pressed(&"move_left"):
		try_move(Vector3.LEFT)
	elif event.is_action_pressed(&"move_right"):
		try_move(Vector3.RIGHT)

#region Movement

var _moving : bool = false

@export var walk_distance : float = 1.0
@export var default_move_duration : float = 0.2 

func try_move(direction : Vector3) -> void:
	if _moving:
		return
	if can_move_to(position + direction * walk_distance):
		_move_and_turn(direction, walk_distance, default_move_duration)
	else:
		_play_fail_anim(default_move_duration)

func can_move_to(point: Vector3) -> bool:
	# TODO: implement
	return true

func _move_and_turn(direction : Vector3, distance : float, duration : float) -> void:
	if _moving:
		return
	_moving = true
	var offset := direction.normalized() * distance
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "position", offset, duration).as_relative()
	if (-basis.z).dot(direction) < 0.9:
		var new_yaw := (-basis.z).signed_angle_to(direction, Vector3.UP)
		#var new_yaw := Basis.looking_at(direction, Vector3.UP).get_euler().y
		tween.parallel().tween_property(self, "rotation:y", new_yaw, duration / 2.0).as_relative()
		#global_rotation.y = new_yaw
	await tween.finished
	_moving = false

func _play_fail_anim(duration : float) -> void:
	if _moving:
		return
	_moving = true
	var old_position := position
	var offset := Vector3.UP * walk_distance / 2
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", offset, duration / 2.0).as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", old_position, duration / 2.0).set_ease(Tween.EASE_OUT)
	await tween.finished
	_moving = false

#endregion
