class_name PlayerRhythmManager
extends Node

# Emitted when the beat was sucessfully consumed (i.e. received player input on time
signal beat_hit(beat_num : int)
# Emitted when the player failed to hit a beat (i.e. next input came too fast)
signal beat_missed(beat_num : int)
# Emitted when no input was received from player during a beat
signal beat_skipped(beat_num : int)

@export var ignore_beat_window : bool = false

var last_consumed_beat : int = -1

func _ready() -> void:
	Rhythm.beat_ended.connect(_on_beat_ended)

func _on_beat_ended(beat_number : int) -> void:
	if beat_number == last_consumed_beat + 1 and last_consumed_beat >= 0:
		print("Player beat skipped at %d (%.3f)" % [beat_number, Rhythm.current_gameplay_beat])
		beat_skipped.emit(beat_number)

func try_consume_beat() -> bool:
	var current_beat : int = Rhythm.get_current_beat_number()
	if Game.config.ignore_rhythm:
		last_consumed_beat = current_beat
		beat_hit.emit(last_consumed_beat)
		return true
	if current_beat < last_consumed_beat:
		push_error("Player beat hangup: %d (%.3f) < %d" % [current_beat, Rhythm.current_gameplay_beat, last_consumed_beat])
		return false
	elif current_beat == last_consumed_beat:
		#last_processed_beat = current_beat + 1
		print("Player beat missed at %d (%.3f)" % [current_beat, Rhythm.current_gameplay_beat])
		beat_missed.emit(current_beat)
		return false
	last_consumed_beat = current_beat
	print("Player beat hit at %d (%.3f)" % [current_beat, Rhythm.current_gameplay_beat])
	beat_hit.emit(last_consumed_beat)
	return true
