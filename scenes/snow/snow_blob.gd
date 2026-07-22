extends Node2D
class_name SnowBlob

@onready var snow_animated_sprite: AnimatedSprite2D = $snowAnimatedSprite

@export var melt_speed : float = 5.0

var melt_amount : float = 0.0
var target_melt_amount : float = 0.0


func _process(delta: float) -> void:
	if melt_amount != target_melt_amount:
		melt_amount = move_toward(
			melt_amount,
			target_melt_amount,
			melt_speed * delta
		)

		update_visual()


func melt_player(amount : float) -> void:
	# player should only melts to middle
	
	#don't change if allready melted more
	if amount < target_melt_amount:
		return
		
	target_melt_amount = clamp(
		target_melt_amount + amount,
		0.0,
		0.8
	)


func melt_oven(amount : float) -> void:
	# oven can fully melt
	target_melt_amount = clamp(
		target_melt_amount + amount,
		0.0,
		1.0
	)


func update_visual() -> void:
	var frame_count := snow_animated_sprite.sprite_frames.get_frame_count("snow")
	var frame := int(
		melt_amount * (frame_count - 1)
	)
	snow_animated_sprite.frame = frame
