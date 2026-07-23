extends Node2D
class_name Hands

@onready var log_hands_animated_sprite_2d: AnimatedSprite2D = $logFRONTHandsAnimatedSprite2D
@onready var log_behind_hands_animated_sprite_2d: AnimatedSprite2D = $"../logBEHINDHandsAnimatedSprite2D"

const DOWN_HANDS_POSITION : Vector2 = Vector2(1.0,-10)
const RIGHT_HANDS_POSITION : Vector2 = Vector2(3.0,-10)
const LEFT_HANDS_POSITION : Vector2 = Vector2(-3.0,-10)

var oven : Oven

#when depositing logs. add some random to it and delay yessss
@export var deposit_delay : float = 0.25
@export var random_flight_duration_min : float = 0.45
@export var random_flight_duration_max : float = 0.7

@export var random_arc_min : float = 10.0
@export var random_arc_max : float = 15.0

@export var max_logs := 3

var carried_fuel : Array[PickupableFuel] = []
var pending_pickups: Array[PickupableFuel] = []
var player_ref : Player

var is_in_oven_deposit_range : bool = false
var is_currently_depositing : bool = false

var should_deposit_again_timer : float = 0.0
const DEPOSIT_CHECK_MAX_TIME : float = 0.5

func _ready() -> void:
	player_ref = get_parent()

func _process(_delta: float) -> void:
	update_log_animation()
	
	should_deposit_again_timer -= _delta
	if should_deposit_again_timer <= 0:
		await check_to_deposit()
		should_deposit_again_timer = DEPOSIT_CHECK_MAX_TIME
			
func pickup(fuel : PickupableFuel) -> void:
	if carried_fuel.size() + pending_pickups.size() >= max_logs:
		return

	pending_pickups.append(fuel)
	fuel.fly_to_player(player_ref)

func finish_pickup(fuel: PickupableFuel) -> void:
	pending_pickups.erase(fuel)
	carried_fuel.append(fuel)

func deposit_into() -> void:
	is_currently_depositing = true
	var logs_to_send := carried_fuel.duplicate()
	oven.lid.open()
	await deposit_logs_sequence(logs_to_send)
	is_currently_depositing = false

func deposit_logs_sequence(logs : Array[PickupableFuel]) -> void:
	for fuel : PickupableFuel in logs:
		if not is_instance_valid(fuel):
			continue
		
		carried_fuel.erase(fuel)
		update_log_animation() # called in process
		
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
	oven.lid.close()
	

func update_log_animation() -> void:
	var log_count := carried_fuel.size()

	#edge case for wierd wstuff
	if log_count > 3:
		push_error("LOG COUNT IS: ", log_count)
		#log_count = 3
		#carried_amount = 3
	
	#edge case for wierd stuff
	if log_count < 0:
		push_error("LOG COUNT IS: ", log_count)
		#carried_amount = 0
		#return
		

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


func check_to_deposit() -> void:
	if not is_in_oven_deposit_range: # don't deposit if player is not in oven range
		return
		
	if carried_fuel.is_empty(): # don't deposit if player has no fuel
		return
	
	await deposit_into()

func _on_deposit_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("oven"):
		
		#safe oven first time
		if not oven:
			oven = area.get_parent()
			
		is_in_oven_deposit_range = true
		if carried_fuel.is_empty():
			return
		
		if is_currently_depositing == false:
			return
			
		is_currently_depositing = true
		await deposit_into()
		
func _on_deposit_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("oven"):
		is_in_oven_deposit_range = false
