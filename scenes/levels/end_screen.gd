extends Node2D

func _ready() -> void:
	Events.storm_state_changed.emit(StormManager.StormState.NONE)
