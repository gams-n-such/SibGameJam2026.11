## Base class for most project-specific state machines
class_name RhythmState
extends State

func beat_start(beat_number : int) -> void:
	pass

func beat_end(beat_number : int) -> void:
	pass
