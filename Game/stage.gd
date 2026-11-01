class_name SibStage
extends Node3D

signal completed

@export var track : RhythmTrack

@export var free_respawn : bool = false

var bpm : float:
	get:
		return track.BPM

func _ready() -> void:
	Rhythm.fade_in_thumper(5.0)

func _process(delta: float) -> void:
	pass


func _on_player_entered_final_trigger(player : Node3D) -> void:
	completed.emit()
