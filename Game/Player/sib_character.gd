class_name SibCharacter
extends AnimatableBody3D

signal move_finished

@onready var rhythm_handler: PlayerRhythmManager = %PlayerRhythmManager

func _ready() -> void:
	Game.player = self
	Rhythm.start()

func _exit_tree() -> void:
	Game.player = null

func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"move_forward"):
		try_move(Vector3.FORWARD)
	elif event.is_action_pressed(&"move_backward"):
		#try_move(Vector3.BACK)
		pass
	elif event.is_action_pressed(&"move_left"):
		try_move(Vector3.LEFT)
	elif event.is_action_pressed(&"move_right"):
		try_move(Vector3.RIGHT)

#region Movement

var _moving : bool = false

@export var walk_distance : float = 1.0
@export var hop_height : float = 0.5
@export var default_move_duration : float = 0.2 

func try_move(direction : Vector3) -> void:
	if _moving:
		return
	if can_move_to(position + direction * walk_distance):
		_move_and_turn(direction, walk_distance, default_move_duration)
	else:
		_play_fail_anim(direction, default_move_duration)

func can_move_to(point: Vector3) -> bool:
	# TODO: implement
	return true

func _play_fail_anim(direction : Vector3, duration : float) -> void:
	_move_and_turn(direction, 0.0, duration, false)

func _move_and_turn(direction : Vector3, distance : float, duration : float, success : bool = true) -> void:
	if _moving:
		return
	if not rhythm_handler.try_consume_beat():
		return
	_moving = true
	
	var hop_tween = get_tree().create_tween().bind_node(self)
	const HOP_TRANS = Tween.TRANS_QUART
	hop_tween.tween_property(self, "position:y", hop_height, duration / 2.0).as_relative().set_trans(HOP_TRANS).set_ease(Tween.EASE_OUT)
	hop_tween.tween_property(self, "position:y", -hop_height, duration / 2.0).as_relative().set_trans(HOP_TRANS).set_ease(Tween.EASE_IN)
	
	var tween = get_tree().create_tween().bind_node(self)
	tween.set_parallel()
	tween.tween_subtween(hop_tween)
	if success:
		var offset := direction.normalized() * distance
		tween.tween_property(self, "position:x", offset.x, duration).as_relative()
		tween.tween_property(self, "position:z", offset.z, duration).as_relative()
	if (-basis.z).dot(direction) < 0.9:
		var new_yaw := (-basis.z).signed_angle_to(direction, Vector3.UP)
		#var new_yaw := Basis.looking_at(direction, Vector3.UP).get_euler().y
		tween.parallel().tween_property(self, "rotation:y", new_yaw, duration / 2.0).as_relative()
		#global_rotation.y = new_yaw
	await tween.finished
	_moving = false
	move_finished.emit()

#endregion
