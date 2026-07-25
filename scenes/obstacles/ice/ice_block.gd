extends Node2D
class_name IceBlock


@export var melt_time := 8.0

@export var min_shake_distance := 0.0
@export var max_shake_distance := 3.5

@export var min_shake_speed := 0.0
@export var max_shake_speed := 35.0

var melt_progress := 0.0 # 0solid 1melted

var is_in_oven_heat_range : bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var horizontal_shaker: HorizontalShaker = $AnimatedSprite2D/HorizontalShaker

var oven : Oven

func _ready() -> void:
	pass
	#current_warmth = max_warmth

func _process(delta: float) -> void:
	if is_in_oven_heat_range:
		update_melting(delta)

	update_visuals()

	if melt_progress >= 1.0:
		remove()

func update_melting(delta: float) -> void:
	if oven == null:
		return

	var heat_percent := oven.get_heat_percentage()
	print(heat_percent)

	melt_progress += (heat_percent / melt_time) * delta
	melt_progress = clamp(melt_progress, 0.0, 1.0)

func update_visuals() -> void:
	var frame_count := animated_sprite_2d.sprite_frames.get_frame_count("ice")

	var frame := int(
		melt_progress * (frame_count - 1)
	)

	animated_sprite_2d.frame = frame

	update_shake()


func remove() -> void:
	pass
	#"should remove collision and player last frame maybe procces=false")
	

func update_shake() -> void:
	if oven == null:
		horizontal_shaker.stop_shaking()
		return

	var heat := oven.get_heat_percentage()

	if heat <= 0.01:
		horizontal_shaker.stop_shaking()
		return

	horizontal_shaker.shake_distance = lerp(
		min_shake_distance,
		max_shake_distance,
		heat
	)

	horizontal_shaker.shake_speed = lerp(
		min_shake_speed,
		max_shake_speed,
		heat
	)

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
		var oven_ref: Oven = parent
		oven = oven_ref
		is_in_oven_heat_range = false
		horizontal_shaker.stop_shaking()
