extends Area2D
class_name SnowMelterPlayer



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("snow"):
		print("hit snow")
		var snow : SnowBlob = area.get_parent()
		snow.melt_player(0.8)
