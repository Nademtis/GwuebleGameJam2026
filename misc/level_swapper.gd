extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("wagon"):
		Events.load_new_level.emit()
