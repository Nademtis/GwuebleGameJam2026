extends Area2D
class_name SnowMelterPlayer

signal hit_snow_tall
signal hit_snow_flat

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("snow"):
		var snow : SnowBlob = area.get_parent()
		#print("melt amount: ", snow.melt_amount)
		
		if snow.melt_amount < 0.4:
			hit_snow_tall.emit()
		elif snow.melt_amount > 0.1 and snow.melt_amount < 0.3:
			hit_snow_flat.emit()

		snow.melt_player(0.8)
