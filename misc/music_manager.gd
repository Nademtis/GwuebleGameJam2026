extends Node
class_name AudioManager

@onready var audio_ambience_interactive: AudioStreamPlayer = $AudioAmbienceInteractive
var interactive_stream: AudioStreamInteractive
var playback: AudioStreamPlaybackInteractive

#use this for when sara is a perfectionist
const NONE_LAYER_BONUS: float = -4.0
const CHILL_LAYER_BONUS: float = 0.0
const MEDIUM_LAYER_BONUS: float = 2.0
const HIGH_LAYER_BONUS: float = 1.0

const STARTUP_VOLUME_DB := -40.0
@export var ambience_volume_lerp_speed := 15.0
var target_ambience_db: float = 0.0

func _ready() -> void:
	Events.connect("storm_state_changed", update_ambience_audio)
	
	audio_ambience_interactive.volume_db = STARTUP_VOLUME_DB
	audio_ambience_interactive.play()
	playback = audio_ambience_interactive.get_stream_playback() as AudioStreamPlaybackInteractive


func _process(delta: float) -> void:
	audio_ambience_interactive.volume_db = move_toward(
		audio_ambience_interactive.volume_db,
		target_ambience_db,
		ambience_volume_lerp_speed * delta
	)

func update_ambience_audio(new_state : StormManager.StormState) -> void:
	#print("from audio Manager, ", new_state)
	playback.switch_to_clip(new_state)
	match new_state:
		StormManager.StormState.NONE:
			target_ambience_db = NONE_LAYER_BONUS

		StormManager.StormState.CHILL:
			target_ambience_db = CHILL_LAYER_BONUS

		StormManager.StormState.MEDIUM:
			target_ambience_db = MEDIUM_LAYER_BONUS

		StormManager.StormState.HIGH:
			target_ambience_db = HIGH_LAYER_BONUS
