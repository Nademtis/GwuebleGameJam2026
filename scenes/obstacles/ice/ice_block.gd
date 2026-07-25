extends Node2D
class_name IceBlock


@export var melt_time := 6.0
@export var melt_heat_curve : Curve

@export var min_shake_distance := 0.0
@export var max_shake_distance := 2.1

@export var min_shake_speed := 0.0
@export var max_shake_speed := 5.0

var melt_progress := 0.0 # 0solid 1melted

var is_in_oven_heat_range : bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var horizontal_shaker: HorizontalShaker = $AnimatedSprite2D/HorizontalShaker

@onready var collision_shape_2d_wagon: CollisionShape2D = $StaticBodyWagonBlocker/CollisionShape2D
@onready var collision_shape_2d_player: CollisionShape2D = $StaticBodyPlayerBlocker/CollisionShape2D


var current_shake_distance := 0.0
var current_shake_speed := 0.0

@export var shake_lerp_speed := 0.8

var oven : Oven

var is_dead : bool = false

func _ready() -> void:
	pass
	#current_warmth = max_warmth

func _process(delta: float) -> void:
	if is_dead:
		set_process(false)
		return
	
	if is_in_oven_heat_range:
		update_melting(delta)

	update_visuals(delta)

	if melt_progress >= 1.0:
		remove()

func update_melting(delta: float) -> void:
	if oven == null:
		return

	var heat_percent := oven.get_heat_percentage()
	#print(heat_percent)

	var melt_multiplier := melt_heat_curve.sample(heat_percent)
	#print("melt multiplayer: ", melt_multiplier)
	melt_progress += (
		melt_multiplier / melt_time
	) * delta
	melt_progress = clamp(melt_progress, 0.0, 1.0)

func update_visuals(delta : float) -> void:
	var frame_count := animated_sprite_2d.sprite_frames.get_frame_count("ice")

	var frame := int(
		melt_progress * (frame_count - 1)
	)

	animated_sprite_2d.frame = frame

	update_shake(delta)


func remove() -> void:
	#animated_sprite_2d.modulate = Color(1.0, 1.0, 1.0, 0.157)
	is_dead = true
	
	collision_shape_2d_wagon.set_deferred("disabled", true)
	collision_shape_2d_player.set_deferred("disabled", true)
	horizontal_shaker.stop_shaking()
	
	#"should remove collision and player last frame maybe procces=false")
	

func update_shake(delta: float) -> void:
	var target_distance := 0.0
	var target_speed := 0.0

	if oven != null:
		var heat := oven.get_heat_percentage()
		var heat_effect := melt_heat_curve.sample(heat)
		
		target_distance = lerp(
			min_shake_distance,
			max_shake_distance,
			heat_effect
		)

		target_speed = lerp(
			min_shake_speed,
			max_shake_speed,
			heat_effect
		)

	current_shake_distance = move_toward(
		current_shake_distance,
		target_distance,
		shake_lerp_speed * delta
	)
	current_shake_speed = move_toward(
		current_shake_speed,
		target_speed,
		shake_lerp_speed * delta
	)

	horizontal_shaker.shake_distance = current_shake_distance
	horizontal_shaker.shake_speed = current_shake_speed

	if not current_shake_distance <= 0.01:
		if not horizontal_shaker.shaking:
			print("starts shaking")
			horizontal_shaker.start_shaking()


func _on_heat_receiver_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()

	if parent is Oven:
		var oven_ref: Oven = parent
		oven = oven_ref
		is_in_oven_heat_range = true
		print("Ice entered heat")


func _on_heat_receiver_area_exited(area: Area2D) -> void:
	var parent := area.get_parent()

	if parent is Oven:
		print("Ice left heat")
		
		var oven_ref: Oven = parent
		oven = oven_ref
		is_in_oven_heat_range = false
		horizontal_shaker.stop_shaking()
