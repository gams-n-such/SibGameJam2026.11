class_name RhythmTracker
extends Control

@onready var target_line: ColorRect = %TargetLine
@onready var beat_bar_template: Control = %BeatBar

@export var queue_size : int = 16
@export var offset_per_beat : float = 70.0

@export var visibility_range : float = 200.0
@export var fade_range : float = 350.0

var queue : Array[Control]
var beats : Dictionary[Control, float]
var _bars_to_requeue : Array[Control]

var last_queued_beat : int = -1

var current_beat : float:
	get:
		return Rhythm.current_gameplay_beat

var beat_window : float:
	get:
		return Rhythm.beat_window_ratio

var fade_duration : float:
	get:
		return Rhythm.beat_duration

func _ready() -> void:
	target_line.size.x = offset_per_beat * Rhythm.beat_window_ratio * 2.0
	target_line.position.x = -target_line.size.x / 2.0
	_create_bars(queue_size)
	Game.player.rhythm_handler.beat_hit.connect(_on_player_beat_hit)

func _process(delta: float) -> void:
	_flush_deferred_requeues()
	for bar in queue:
		_update_bar_position(bar, beats[bar])
		_update_bar_visibility(bar)
	_unqueue_deferred_requeues()

func _create_bars(num_bars : int) -> void:
	queue.clear()
	beats.clear()
	_bars_to_requeue.clear()
	last_queued_beat = -1
	_requeue(beat_bar_template, true)
	for bar_idx in range(num_bars):
		var new_bar := beat_bar_template.duplicate() as Control
		target_line.add_child(new_bar)
		_requeue(new_bar, true)

func _update_bar_position(bar : Control, target_beat : float, current_beat_override : float = -1.0) -> void:
	var effective_current_beat := current_beat_override if current_beat_override >= 0.0 else current_beat
	var target_x := target_line.size.x / 2.0
	bar.position.x = (target_beat - effective_current_beat) * offset_per_beat + target_x
	if bar.position.x <= target_x:
		requeue_deferred(bar)

func _update_bar_visibility(bar : Control) -> void:
	if bar.position.x < visibility_range:
		bar.modulate.a = 1.0
	elif bar.position.x > fade_range:
		bar.modulate.a = 0.0
	else:
		bar.modulate.a = remap(bar.position.x, visibility_range, fade_range, 1.0, 0.0)

func requeue_deferred(bar : Control) -> void:
	if not _bars_to_requeue.has(bar):
		_bars_to_requeue.append(bar)

func _flush_deferred_requeues() -> void:
	for bar in _bars_to_requeue:
		_requeue(bar)
	_bars_to_requeue.clear()

func _unqueue_deferred_requeues() -> void:
	for bar in _bars_to_requeue:
		queue.erase(bar)

func fade_and_requeue(bar : Control) -> void:
	queue.erase(bar)
	var fade_tween := get_tree().create_tween()
	fade_tween.tween_property(bar, "modulate", Color.TRANSPARENT, fade_duration)
	await fade_tween.finished
	bar.modulate = Color.WHITE
	requeue_deferred(bar)

func _on_player_beat_hit(beat_num : int) -> void:
	fade_and_requeue(queue[0])

func _requeue(bar : Control, update : bool = false) -> void:
	last_queued_beat += 1
	#print("Queueing beat %d" % last_queued_beat)
	queue.append(bar)
	beats.set(bar, last_queued_beat + beat_window)
	(bar.get_node("BeatLabel") as Label).text = str(last_queued_beat)
	if update:
		_update_bar_position(bar, beats[bar])
