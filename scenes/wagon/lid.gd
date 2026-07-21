extends AnimatedSprite2D
class_name Lid

func open() -> void:
		play("open")
	
func close() -> void:
		play("close")
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
		#open_lid()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
		#play("close")
