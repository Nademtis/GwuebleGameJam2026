extends Node2D
class_name Hands

@onready var log_hands_animated_sprite_2d: AnimatedSprite2D = $logFRONTHandsAnimatedSprite2D
@onready var log_behind_hands_animated_sprite_2d: AnimatedSprite2D = $"../logBEHINDHandsAnimatedSprite2D"
const DOWN_HANDS_POSITION : Vector2 = Vector2(1.0,-10)
const RIGHT_HANDS_POSITION : Vector2 = Vector2(3.0,-10)
const LEFT_HANDS_POSITION : Vector2 = Vector2(-3.0,-10)



@export var max_logs := 3

var carried_fuel : Array[PickupableFuel] = []
var player_ref : Player

func _ready() -> void:
	player_ref = get_parent()
	

func _process(_delta: float) -> void:
	update_log_animation()

func pickup(fuel : PickupableFuel) -> void:
	if carried_fuel.size() >= max_logs:
		print("hands filled - not pickup")
		return

	carried_fuel.append(fuel)
	fuel.visible = false


func deposit_into(oven : Oven) -> void:
	#print("should deposit to oven")
	#var fuel_to_deposit = carried_fuel.pop_front()
	for fuel : PickupableFuel in carried_fuel:
		oven.add_fuel(fuel)
		carried_fuel.pop_front()
		print("deposited to oven")
		#fuel.queue_free()


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
		deposit_into(area.get_parent())
