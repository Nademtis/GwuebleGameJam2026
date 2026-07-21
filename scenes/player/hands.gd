extends Node2D
class_name Hands

@export var max_logs := 3

var carried_fuel : Array[PickupableFuel] = []

func pickup(fuel : PickupableFuel) -> void:
	if carried_fuel.size() >= max_logs:
		return

	carried_fuel.append(fuel)

	fuel.visible = false


func deposit_into(oven : Oven) -> void:
	print("should deposit to oven")
	for fuel : PickupableFuel in carried_fuel:
		oven.add_fuel(fuel)
		print("deposited to oven")
		#fuel.queue_free()



func _on_pickup_area_area_entered(area: Area2D) -> void:
	var fuel := area.get_parent() as PickupableFuel
	if fuel:
		pickup(fuel)


func _on_deposit_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("oven"):
		deposit_into(area.get_parent())
