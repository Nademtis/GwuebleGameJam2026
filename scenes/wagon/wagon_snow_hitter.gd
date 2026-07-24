extends Area2D
class_name WagonSnowHitter

signal hit_snow

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("snow"):
		#print("hit snow")
		var snow : SnowBlob = area.get_parent()
		
		if snow.melt_amount < 0.5:
			hit_snow.emit()
			print("wagon hit snow")
			snow.melt_player(0.8)
		else: 
			print("snow is gone")
