extends Node2D
class_name Hands

@onready var log_hands_animated_sprite_2d: AnimatedSprite2D = $logFRONTHandsAnimatedSprite2D
@onready var log_behind_hands_animated_sprite_2d: AnimatedSprite2D = $"../logBEHINDHandsAnimatedSprite2D"
const DOWN_HANDS_POSITION : Vector2 = Vector2(1.0,-10)
const RIGHT_HANDS_POSITION : Vector2 = Vector2(3.0,-10)
const LEFT_HANDS_POSITION : Vector2 = Vector2(-3.0,-10)


#when depositing logs. add some random to it and delay yessss
@export var deposit_delay : float = 0.25
@export var random_flight_duration_min : float = 0.45
@export var random_flight_duration_max : float = 0.7

@export var random_arc_min : float = 10.0
@export var random_arc_max : float = 15.0

@export var max_logs := 3

var carried_fuel : Array[PickupableFuel] = []
var player_ref : Player

func _ready() -> void:
	player_ref = get_parent()
	

func _process(_delta: float) -> void:
	update_log_animation()

func pickup(fuel : PickupableFuel) -> void:
	if carried_fuel.size() >= max_logs:
		#print("hands filled - not pickup")
		return

	fuel.fly_to_player(player_ref)

func finish_pickup(fuel : PickupableFuel) -> void:
	carried_fuel.append(fuel)
	update_log_animation()

func deposit_into(oven : Oven) -> void:
	var logs_to_send := carried_fuel.duplicate()
	oven.lid.open()
	await deposit_logs_sequence(logs_to_send, oven)

func deposit_logs_sequence(logs : Array[PickupableFuel], oven : Oven) -> void:

	for fuel : PickupableFuel in logs:
		# remove one log visually from hands
		carried_fuel.erase(fuel)
		update_log_animation()
		fuel.global_position = player_ref.global_position
		
		fuel.oven_flight_duration = randf_range(
			random_flight_duration_min,
			random_flight_duration_max
		)
		
		fuel.oven_arc_height = randf_range(
			random_arc_min,
			random_arc_max
		)

		fuel.fly_to_oven(oven)
		await get_tree().create_timer(deposit_delay).timeout
	await get_tree().create_timer(deposit_delay).timeout
	oven.lid.close()
	

func update_log_animation() -> void:
	var log_count := carried_fuel.size()

	# Hide both when empty
	if log_count == 0:
		log_hands_animated_sprite_2d.visible = false
		log_behind_hands_animated_sprite_2d.visible = false
		return

	var sprite: AnimatedSprite2D
	var direction := "down"

	if abs(player_ref.input_dir.x) > abs(player_ref.input_dir.y):
		# Walking left/right
		log_hands_animated_sprite_2d.visible = true
		log_behind_hands_animated_sprite_2d.visible = false

		direction = "right"

		if player_ref.input_dir.x < 0:
			log_hands_animated_sprite_2d.flip_h = true
			log_hands_animated_sprite_2d.position = LEFT_HANDS_POSITION
		else:
			log_hands_animated_sprite_2d.flip_h = false
			log_hands_animated_sprite_2d.position = RIGHT_HANDS_POSITION

		sprite = log_hands_animated_sprite_2d

	else:
		if player_ref.input_dir.y < 0:
			# Walking up -> logs behind player
			log_hands_animated_sprite_2d.visible = false
			log_behind_hands_animated_sprite_2d.visible = true

			log_behind_hands_animated_sprite_2d.flip_h = false
			sprite = log_behind_hands_animated_sprite_2d
		else:
			# Walking down (or idle) -> logs in front
			log_hands_animated_sprite_2d.visible = true
			log_behind_hands_animated_sprite_2d.visible = false

			log_hands_animated_sprite_2d.flip_h = false
			log_hands_animated_sprite_2d.position = DOWN_HANDS_POSITION

			sprite = log_hands_animated_sprite_2d
		direction = "down"
	sprite.play("%s_%d_log" % [direction, log_count])


func _on_pickup_area_area_entered(area: Area2D) -> void:
	var fuel := area.get_parent() as PickupableFuel
	if fuel:
		pickup(fuel)


func _on_deposit_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("oven"):
		var oven : Oven = area.get_parent()
		if carried_fuel.is_empty():
			return
		await deposit_into(oven)
