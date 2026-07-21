extends Node2D
class_name Oven

@export var max_heat : float = 50.0

var heat : float = 0.0
var fuel_queue : Array[PickupableFuel] = []

func _ready() -> void:
	heat = max_heat

func _process(delta : float) -> void:
	heat -= delta

func add_fuel(fuel : PickupableFuel) -> void:
	heat += fuel.heat
	heat = clamp(heat,0.0, max_heat)
	print("added heat - new heat: ", heat)
	
