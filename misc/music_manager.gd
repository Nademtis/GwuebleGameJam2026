extends Node
class_name AudioManager


func _ready() -> void:
	Events.connect("storm_state_changed", update_ambience_audio)
	
	
func update_ambience_audio(new_state : StormManager.StormState) -> void:
	print("from audio Manager, ", new_state)
