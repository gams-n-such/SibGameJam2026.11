class_name RhythmManager
extends Node

signal beat_started(beat_number : int)
signal beat_ended(beat_number : int)
signal track_looped

@onready var rhythm_notifier: RhythmNotifier = %RhythmNotifier
@onready var music_player: AudioStreamPlayer = %MusicPlayer

func _ready():
	pass

# Hack to detect track loops
var _last_frame_music_time : float = -1.0

func _process(_delta: float) -> void:
	if music_player.get_playback_position() < _last_frame_music_time:
		_on_music_looped()
	_last_frame_music_time = music_player.get_playback_position()

func _reset_state() -> void:
	reset_loops()
	music_player.seek(0.0)
	rhythm_notifier._position = 0.0

#region Rhythm

@export_category("Rhythm")
@export var track : RhythmTrack = null

## The ideal perfect perfect point of the beat
@export_range(0.0, 0.99, 0.01) var sweetspot : float = 0.0
## If 1 is the full beat length and 0 < X < 1 is the "sweet spot", you need to hit the beat no earlier than X - beat_window.x and no later than X + beat_window.y
# FIXME: rework beat windows system. Currently only using .x for pre-beat acceptance interval
@export var beat_window : Vector2 = Vector2(0.4, 0.1)
## How big is the acceptance window relative to the beat duration
var beat_window_ratio : float:
	get:
		return beat_window.x + beat_window.y

#var on_beat : bool = false

var beat_duration : float:
	get:
		return rhythm_notifier.beat_length

func is_on_beat() -> bool:
	var current_beat := current_gameplay_beat
	return (current_beat - floorf(current_beat)) < beat_window_ratio

# Account for different hardware setups
var latency_seconds : float = 0.0
var latency_beats : float:
	get:
		return latency_seconds / beat_duration

var track_start_offset_seconds : float = 0.0
var track_start_offset_beats : float:
	get:
		return track_start_offset_seconds / beat_duration

var gameplay_start_seconds : float:
	get:
		return track_start_offset_seconds + latency_seconds
var gameplay_start_beats : float:
	get:
		return gameplay_start_seconds / beat_duration

## These take into account beat sweet spot and beat window, along with other offsets, so that we can simplify beat checks
var _beats_to_first_window_cached : float = 0.0
var _seconds_to_first_window_cached : float = 0.0

func _cache_first_window_offsets() -> void:
	_beats_to_first_window_cached = gameplay_start_beats + sweetspot - beat_window.x
	# TODO: revisit
	if _beats_to_first_window_cached < 0.0:
		_beats_to_first_window_cached += -ceilf(_beats_to_first_window_cached) + 1
	_seconds_to_first_window_cached = _beats_to_first_window_cached * beat_duration

#endregion

#region Playback

var playing : bool:
	get:
		return music_player.playing or rhythm_notifier.running

func _on_beat_started(_beat_number : int) -> void:
	#on_beat = true
	var internal_beat_number := _beat_number + _accumulated_loop_beats
	if internal_beat_number > 0:
		print_verbose("BEAT END: %d = %.3f (%.3f)" % [internal_beat_number - 1, current_gameplay_beat, current_notifier_beat])
		beat_ended.emit(internal_beat_number - 1)
	# TODO: beat 0 does not start
	print_verbose("BEAT START: %d = %.3f (%.3f)" % [internal_beat_number, current_gameplay_beat, current_notifier_beat])
	beat_started.emit(internal_beat_number)

#func _on_beat_ended(_beat_number : int) -> void:
	#on_beat = false
	##print("BEAT END : %.3f (%.3f)" % [current_gameplay_beat, current_notifier_beat])
	#beat_ended.emit(_beat_number)

var current_notifier_beat : float:
	get:
		return rhythm_notifier.current_position / rhythm_notifier.beat_length

var current_gameplay_beat : float:
	get:
		return _accumulated_loop_beats + current_notifier_beat - _beats_to_first_window_cached

func get_current_beat_number() -> int:
	return int(floorf(current_gameplay_beat))

func start() -> void:
	if playing:
		return
	assert(track)
	_reset_state()
	rhythm_notifier.bpm = track.BPM
	if track.audio:
		music_player.stream = track.audio
		_listen_for_beats()
		music_player.play()
		_on_music_started()
	else:
		rhythm_notifier.running = true

func stop() -> void:
	if not playing and not get_tree().paused:
		return
	music_player.stop()
	rhythm_notifier.running = false
	_stop_listening_for_beats()

#endregion

#region Signals

var _connected : bool = false

var _beat_start_signal : Signal
#var _beat_end_signal : Signal

var playback_position_seconds : float:
	get:
		return rhythm_notifier.current_position

func _listen_for_beats() -> void:
	if not _connected:
		_cache_first_window_offsets()
		_beat_start_signal = rhythm_notifier.beats(1.0, true, _beats_to_first_window_cached)
		_beat_start_signal.connect(_on_beat_started)
		#_beat_end_signal = rhythm_notifier.beats(1.0, true, _beats_to_first_window_cached + beat_window_ratio)
		#_beat_end_signal.connect(_on_beat_ended)
		_connected = true

func _stop_listening_for_beats() -> void:
	if _connected:
		_beat_start_signal.disconnect(_on_beat_started)
		_beat_start_signal = Signal()
		#_beat_end_signal.disconnect(_on_beat_ended)
		#_beat_end_signal = Signal()
		_connected = false

func _on_music_started() -> void:
	if track.loops:
		_on_music_looped()

func _on_music_player_finished() -> void:
	if not track.loops:
		Game.on_track_ended()

#endregion

#region Loops

var _accumulated_loops : int = -1
var _accumulated_loop_beats : int = 0

func _on_music_looped() -> void:
	if _accumulated_loops >= 0:
		_accumulated_loops += 1
		_accumulated_loop_beats += int(roundf(track.beats))
		print_verbose("Accumulated %d loop beats" % int(roundf(track.beats)))
		track_looped.emit()
	else:
		_accumulated_loops = 0
	print("Music loop %d started" % [_accumulated_loops])

func reset_loops() -> void:
	_accumulated_loops = -1
	_accumulated_loop_beats = 0

#endregion
