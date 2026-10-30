class_name RhythmStateMachine
extends StateMachine

var current_rhythm_state : RhythmState:
	get:
		return current_state as RhythmState

func _ready() -> void:
	# FIXME: set expected state class in base StateMachine?
	for child in get_children():
		if not child is RhythmState:
			push_warning("State machine %s contains incompatible child node %s" % [get_path(), child.name])
	
	Rhythm.beat_started.connect(_on_beat_started)
	Rhythm.beat_ended.connect(_on_beat_ended)
	
	await super._ready()

func _on_beat_started(beat_number : int) -> void:
	if current_rhythm_state:
		current_rhythm_state.beat_start(beat_number)

func _on_beat_ended(beat_number : int) -> void:
	if current_rhythm_state:
		current_rhythm_state.beat_end(beat_number)
