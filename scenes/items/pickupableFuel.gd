extends Node2D
class_name PickupableFuel

@export var heat : float = 5
@export var weight : float = 0.1
@export var type : FuelType = FuelType.LOG

enum FuelType {
	LOG,
}
