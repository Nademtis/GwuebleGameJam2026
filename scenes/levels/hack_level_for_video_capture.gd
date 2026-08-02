extends Node2D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		Events.emit_signal("load_new_level")
