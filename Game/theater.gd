class_name SibTheater
extends Node3D


@export var segments : Array[PackedScene]
var current_segment_idx : int = -1
var next_segment_idx : int:
	get:
		return current_segment_idx + 1
var current_segment_scene : PackedScene:
	get:
		if current_segment_idx < 0 or current_segment_idx >= segments.size():
			return null
		else:
			return segments[current_segment_idx]
var current_segment : SibStage = null

var player : SibCharacter:
	get:
		return Game.player

func _ready() -> void:
	Game.theater = self
	current_segment_idx = Game.last_segment_reached - 1
	Game.change_game_state(GameState.GAMEPLAY)
	play()

func play() -> void:
	reset_player_position()
	Game.player.detected.connect(_on_player_detected)
	start_next_segment()
	Rhythm.start()
	while current_segment:
		await current_segment.completed
		if next_segment_idx < segments.size():
			start_next_segment()
		else:
			play_victory()
		if not current_segment_scene:
			play_victory()
			return

func reset_player_position() -> void:
	if player._moving:
		await player.move_finished
	Game.player.position = Vector3.ZERO

func start_next_segment() -> void:
	current_segment_idx += 1
	if current_segment:
		# TODO: move out
		# TODO: await
		remove_child(current_segment)
		current_segment.queue_free()
		current_segment = null
		reset_player_position()
	if current_segment_scene:
		current_segment = current_segment_scene.instantiate() as SibStage
		# TODO: move in
		add_child(current_segment)
		Rhythm.restart()

func play_victory() -> void:
	print("WON?")

func _on_player_detected() -> void:
	print("LOST")
