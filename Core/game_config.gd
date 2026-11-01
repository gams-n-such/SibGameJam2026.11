class_name GameConfig
extends Resource

@export_range(0.1, 1.0, 0.01) var player_move_beats : float = 0.5
var player_move_seconds : float:
	get:
		return Rhythm.beat_duration * player_move_beats

@export_range(0.1, 1.0, 0.01) var object_move_beats : float = 0.3
var object_move_seconds : float:
	get:
		return Rhythm.beat_duration * object_move_beats

@export var ignore_rhythm : bool = false
