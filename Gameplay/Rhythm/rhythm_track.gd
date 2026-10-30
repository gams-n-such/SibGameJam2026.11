class_name RhythmTrack
extends Resource

@export var BPM : float = 120.0
# When the first beat of the music starts
@export var start_offset_seconds : float = 0.0
@export var audio : AudioStream = null
var import_filepath : String = ""

var length : float:
	get:
		return audio.get_length()

var beat_length : float:
	get:
		return 60.0 / BPM

var beats : float:
	get:
		return length / beat_length

var loops : bool:
	get:
		if audio is AudioStreamMP3:
			return (audio as AudioStreamMP3).loop
		elif audio is AudioStreamWAV:
			return (audio as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_FORWARD
		return false
