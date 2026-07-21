extends Node2D
class_name PickupableFuel

@onready var pickup_range_area: Area2D = $pickupRangeArea

@export var heat : float = 5
@export var weight : float = 0.1
@export var type : FuelType = FuelType.LOG

@onready var shadow: Sprite2D = $shadow

enum FuelType {
	LOG,
}

#from ground --> player
var flying_to_player := false
var target_player : Node2D
var fly_speed := 50.0
var max_fly_speed := 500.0
var acceleration := 900.0

#from player--> oven
var flying_to_oven := false
var target_oven : Oven
var start_position : Vector2
var end_position : Vector2
var flight_time : float = 0.0
@export var oven_flight_duration : float = 0.6
@export var oven_arc_height : float = 80.0
@export var oven_acceleration_curve : Curve

#log shadow
@export var shadow_min_scale : float = 0.3
@export var shadow_max_scale : float = 1.0
@export var shadow_height_fade : float = 0.75
var shadow_start_position : Vector2
var shadow_end_position : Vector2

func _process(delta: float) -> void:
	if flying_to_player:
		fly_to_player_process(delta)

	if flying_to_oven:
		fly_to_oven_process(delta)

func fly_to_oven(oven : Oven) -> void:

	self.z_index += 1

	target_oven = oven
	flying_to_oven = true
	visible = true

	start_position = global_position
	end_position = oven.global_position

	# shadow stays on ground
	shadow_start_position = start_position
	shadow_end_position = end_position

	flight_time = 0.0
	pickup_range_area.set_deferred("monitoring", false)

func fly_to_player(player: Node2D) -> void:
	target_player = player
	flying_to_player = true
	
	pickup_range_area.set_deferred("monitorable", false)

func fly_to_player_process(delta : float) -> void:
	var direction := global_position.direction_to(target_player.global_position)

	fly_speed = move_toward(
		fly_speed,
		max_fly_speed,
		acceleration * delta
	)

	global_position += direction * fly_speed * delta


	if global_position.distance_to(target_player.global_position) < 5:
		finish_pickup()

func fly_to_oven_process(delta : float) -> void:

	flight_time += delta
	var progress := flight_time / oven_flight_duration
	progress = clamp(progress,0.0,1.0)

	var curved_progress := progress
	if oven_acceleration_curve:
		curved_progress = oven_acceleration_curve.sample(progress)
	else:
		# slow start, fast end
		curved_progress = pow(progress, 2.5)

	# move horizontally
	var fuel_position := start_position.lerp(
		end_position,
		curved_progress
	)
	# adds arc
	var height := sin(progress * PI) * oven_arc_height
	fuel_position.y -= height
	
	update_shadow(progress, height)
	
	global_position = fuel_position
	if progress >= 1.0:
		finish_oven_deposit()

func update_shadow(progress : float, height : float) -> void:

	# linear movement along ground
	shadow.global_position = shadow_start_position.lerp(
		shadow_end_position,
		progress
	)
	# shrink when higher
	var height_percent := height / oven_arc_height

	var scale_amount : float = lerp(
		shadow_max_scale,
		shadow_min_scale,
		height_percent
	)

	shadow.scale = Vector2.ONE * scale_amount

	# fades when high
	shadow.modulate.a = lerp(
		1.0,
		shadow_height_fade,
		height_percent
	)

func finish_pickup() -> void:
	flying_to_player = false
	visible = false
	
	var hands := target_player.get_node("Hands") as Hands
	hands.finish_pickup(self)

func finish_oven_deposit() -> void:
	flying_to_oven = false
	target_oven.add_fuel(self)
	queue_free()
