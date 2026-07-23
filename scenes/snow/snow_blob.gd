extends Node2D
class_name SnowBlob

@onready var meltbox: CollisionShape2D = $meltArea/meltbox
@onready var snow_animated_sprite: AnimatedSprite2D = $snowAnimatedSprite


@export var melt_speed: float = 5.0

var melt_amount: float = 0.0
var target_melt_amount: float = 0.0


func _ready() -> void:
	set_process(false)
	snow_animated_sprite.frame = 0


func _process(delta: float) -> void:

	melt_amount = move_toward(
		melt_amount,
		target_melt_amount,
		melt_speed * delta
	)

	update_visual()

	if is_equal_approx(melt_amount, target_melt_amount):
		set_process(false)


func start_melting() -> void:
	set_process(true)


func melt_player(amount: float) -> void:

	if amount < target_melt_amount:
		return

	target_melt_amount = clamp(
		target_melt_amount + amount,
		0.0,
		0.8
	)
	start_melting()

func melt_oven(amount: float) -> void:
	target_melt_amount = clamp(
		target_melt_amount + amount,
		0.0,
		1.0
	)

	start_melting()

func update_visual() -> void:

	var frame_count := snow_animated_sprite.sprite_frames.get_frame_count("snow")

	snow_animated_sprite.frame = int(
		melt_amount * (frame_count - 1)
	)
