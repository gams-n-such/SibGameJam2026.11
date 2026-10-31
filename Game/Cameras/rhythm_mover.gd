@tool
class_name SibRhythmMover
extends Node3D

var _beat_signal : Signal:
	get:
		return Rhythm.beat_started

@export var first_beat : int = 0
@export var starting_state_idx : int = 0
@export var states : Array[NodeRhythmState]
var num_states : int:
	get:
		return states.size()
var current_state_idx : int = 0
var current_state : NodeRhythmState:
	get:
		if current_state_idx >= num_states:
			return null
		else:
			return states[current_state_idx]
var beats_passed_in_state : int = 0

#region Tool

@warning_ignore("unused_private_class_variable")
@export_tool_button("Capture State") var _tool_snapshot := _make_snapshot

func _make_snapshot() -> void:
	var new_state := NodeRhythmState.new()
	new_state.position = position
	new_state.rotation = rotation
	new_state.scale = scale
	states.append(new_state)
	notify_property_list_changed()

#endregion

func _ready() -> void:
	if not Engine.is_editor_hint():
		assert(not states.is_empty())
		_beat_signal.connect(_on_beat)
		skip_to_state(starting_state_idx)

func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		_beat_signal.disconnect(_on_beat)


func _process(delta: float) -> void:
	pass

func _on_beat(beat_num : int) -> void:
	if beat_num < first_beat:
		return
	advance_current_state()

func advance_current_state() -> void:
	beats_passed_in_state += 1
	if beats_passed_in_state >= current_state.beats_duration:
		transition_to_next_state()

var _move_duration : float:
	get:
		return Game.config.object_move_seconds

func transition_to_next_state() -> void:
	transition_to_state(current_state_idx + 1)

func transition_to_state(state_idx : int) -> void:
	current_state_idx = (state_idx) % num_states
	beats_passed_in_state = 0
	var state := current_state
	var tween := get_tree().create_tween().bind_node(self)
	tween.set_parallel(true)
	tween.tween_property(self, "position", state.position, _move_duration)
	tween.tween_property(self, "rotation", state.rotation, _move_duration)
	tween.tween_property(self, "scale", state.scale, _move_duration)

func skip_to_state(state_idx : int) -> void:
	current_state_idx = (state_idx) % num_states
	beats_passed_in_state = 0
	var state := current_state
	position = state.position
	rotation = state.rotation
	scale = state.scale
