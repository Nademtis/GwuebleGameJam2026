extends Node2D
class_name PickupableFuel

@onready var pickup_range_area: Area2D = $pickupRangeArea

@export var heat : float = 5
@export var weight : float = 0.1
@export var type : FuelType = FuelType.LOG

enum FuelType {
	LOG,
}

var flying_to_player := false
var target_player : Node2D

var fly_speed := 50.0
var max_fly_speed := 500.0
var acceleration := 900.0


func fly_to_player(player: Node2D) -> void:
	target_player = player
	flying_to_player = true
	
	pickup_range_area.set_deferred("monitorable", false)


func _process(delta: float) -> void:
	if not flying_to_player:
		return

	var direction := global_position.direction_to(target_player.global_position)

	# accelerate over time
	fly_speed = move_toward(
		fly_speed,
		max_fly_speed,
		acceleration * delta
	)

	global_position += direction * fly_speed * delta

	# close enough in pixels
	if global_position.distance_to(target_player.global_position) < 5:
		finish_pickup()


func finish_pickup() -> void:
	flying_to_player = false
	visible = false
	
	var hands := target_player.get_node("Hands") as Hands
	hands.finish_pickup(self)
