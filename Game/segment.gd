class_name SibSegment
extends Node3D

signal segment_completed

@export var track : RhythmTrack

var bpm : float:
	get:
		return track.BPM

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass


func _on_player_entered_final_trigger(player : Node3D) -> void:
	segment_completed.emit()
