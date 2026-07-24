extends Area2D
class_name SnowMelterPlayer

signal hit_snow

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("snow"):
		var snow : SnowBlob = area.get_parent()
		
		if snow.melt_amount < 0.2:
			hit_snow.emit()
		snow.melt_player(0.8)
