extends CharacterBody2D
class_name Player

@export var max_speed: float = 65
@export var acceleration: float = 260.0
@export var deceleration: float = 260.0

#snow stuff
@export var snow_speed_multiplier := 1.0
@export var snow_hit_multiplier := 0.8
@export var snow_recovery_speed := 2.5


@onready var animated_sprite_2d: AnimatedSprite2D = $HorizontalShaker/AnimatedSprite2D

var can_move : bool = true
var input_dir: Vector2
var move_dir: Vector2

var is_pushing : bool = false
var push_direction_is_right : bool = false

func _physics_process(delta : float) -> void:
	snow_speed_multiplier = move_toward(
		snow_speed_multiplier,
		1.0,
		snow_recovery_speed * delta
	)
	if is_pushing:
		velocity = Vector2.ZERO
		_update_push_animation()
		return

	if can_move:
		_movement(delta)

	move_and_slide()

func _process(_delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	

func _movement(delta: float) -> void:
	if input_dir != Vector2.ZERO:
		#last_move_dir = input_dir.normalized()
		_update_animation(input_dir)
		velocity = velocity.move_toward(
			input_dir * max_speed * snow_speed_multiplier,
			acceleration * delta
		)
	else:
		_update_animation(Vector2.ZERO)
		velocity = velocity.move_toward(
			Vector2.ZERO,
			deceleration * delta
		)
		
func _update_push_animation() -> void:
	if push_direction_is_right:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true
	animated_sprite_2d.play("p_right")
	

func _update_animation(dir: Vector2) -> void:

	#todo should be idle
	animated_sprite_2d.play("w_down")
	
	if dir == Vector2.ZERO:
		#animated_sprite_2d.play("idle")
		return

	if abs(dir.x) > abs(dir.y):
		animated_sprite_2d.play("w_right")
		animated_sprite_2d.flip_h = dir.x < 0
	else:
		animated_sprite_2d.flip_h = false
		if dir.y < 0:
			animated_sprite_2d.play("w_up")
		else:
			animated_sprite_2d.play("w_down")


func _on_snow_melter_area_hit_snow() -> void:
	#print("player hit snow")
	snow_speed_multiplier *= snow_hit_multiplier
	snow_speed_multiplier = max(snow_speed_multiplier, 0.5)
