## Base class for most project-specific state machines
class_name RhythmState
extends State

var grid : Grid3D:
	get:
		return Game.grid

func beat_start(beat_number : int) -> void:
	pass

func beat_end(beat_number : int) -> void:
	pass
