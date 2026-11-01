class_name SibTheater
extends Node3D


@export var segments : Array[PackedScene]
var current_segment_idx : int = -1
var current_segment_scene : PackedScene:
	get:
		if current_segment_idx < 0 or current_segment_idx >= segments.size():
			return null
		else:
			return segments[current_segment_idx]
var current_segment : SibSegment = null

var player : SibCharacter:
	get:
		return Game.player

func _ready() -> void:
	current_segment_idx = Game.last_segment_reached - 1
	Game.change_game_state(GameState.GAMEPLAY)
	play()

func _process(delta: float) -> void:
	pass

func play() -> void:
	reset_player_position()
	start_next_segment()
	Rhythm.fade_in_thumper(5.0)

func reset_player_position() -> void:
	if player._moving:
		await player.move_finished
	Game.player.position = Vector3.ZERO

func start_next_segment() -> void:
	current_segment_idx += 1
	if not current_segment_scene:
		play_victory()
		return
	if current_segment:
		# TODO: move out
		# TODO: await
		current_segment.queue_free()
		reset_player_position()
	current_segment = current_segment_scene.instantiate() as SibSegment
	# TODO: move in
	add_child(current_segment)
	Rhythm.track = current_segment.track
	Rhythm.restart()

func play_victory() -> void:
	pass
