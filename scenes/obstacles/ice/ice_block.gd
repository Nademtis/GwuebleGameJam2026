extends Node2D
class_name IceBlock


@export var melt_time := 6.0
@export var melt_heat_curve : Curve

@export var min_shake_distance := 0.0
@export var max_shake_distance := 1.5

@export var min_shake_speed := 0.0
@export var max_shake_speed := 3.0

var melt_progress := 0.0 # 0solid 1melted

var is_in_oven_heat_range : bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var horizontal_shaker: HorizontalShaker = $AnimatedSprite2D/HorizontalShaker

@onready var collision_shape_2d_wagon: CollisionShape2D = $StaticBodyWagonBlocker/CollisionShape2D
@onready var collision_shape_2d_player: CollisionShape2D = $StaticBodyPlayerBlocker/CollisionShape2D

@onready var audio_ice_melting: AudioStreamPlayer2D = $audioIceMelting
#region audio

@export_group("Ice Melting Audio")

@export var min_melting_volume_db := -20.0
@export var max_melting_volume_db := 15.0

@export var melting_audio_lerp_speed := 25.0

var current_melting_audio_db := -40.0
@export var audio_stop_threshold := -79.0
#endregion


var current_shake_distance := 0.0
var current_shake_speed := 0.0

@export var shake_lerp_speed := 0.8

var oven : Oven

var is_dead : bool = false

func _ready() -> void:
	audio_ice_melting.volume_db = min_melting_volume_db
	audio_ice_melting.play()

func _process(delta: float) -> void:
	if is_dead:
		update_melting_audio(delta)
		if audio_ice_melting.volume_db <= audio_stop_threshold:
			audio_ice_melting.stop()
		return
	
	
	if is_in_oven_heat_range:
		update_melting(delta)
	
	#print("ice playing with: ", current_melting_audio_db)
	update_melting_audio(delta)
	update_visuals(delta)

	if melt_progress >= 1.0:
		remove()

func update_melting(delta: float) -> void:
	if oven == null:
		return

	var heat_percent := oven.get_heat_percentage()
	#(heat_percent)

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
	#min_melting_volume_db = -80
	#max_melting_volume_db = -40
	
	
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
			#print("starts shaking")
			horizontal_shaker.start_shaking()

func update_melting_audio(delta: float) -> void:
	var melt_strength := 0.0

	if oven != null and is_in_oven_heat_range:
		var heat := oven.get_heat_percentage()
		melt_strength = melt_heat_curve.sample(heat)

	var target_db : float = lerp(
		min_melting_volume_db,
		max_melting_volume_db,
		melt_strength
	)
	#print("target DB, ", target_db)

	audio_ice_melting.volume_db = move_toward(
		audio_ice_melting.volume_db,
		target_db,
		melting_audio_lerp_speed * delta
	)


func _on_heat_receiver_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()

	if parent is Oven:
		var oven_ref: Oven = parent
		oven = oven_ref
		is_in_oven_heat_range = true
		#print("Ice entered heat")


func _on_heat_receiver_area_exited(area: Area2D) -> void:
	var parent := area.get_parent()

	if parent is Oven:
		#print("Ice left heat")
		var oven_ref: Oven = parent
		oven = oven_ref
		is_in_oven_heat_range = false
		horizontal_shaker.stop_shaking()
