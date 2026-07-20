extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var max_speed: float = 95
@export var acceleration: float = 350.0
@export var deceleration: float = 425.0

var can_move : bool = true
var input_dir: Vector2
var move_dir: Vector2


func _physics_process(delta: float) -> void:
	if can_move:
		_movement(delta)
	move_and_slide()
	
func _movement(delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

	if input_dir != Vector2.ZERO:
		#last_move_dir = input_dir.normalized()
		_update_animation(input_dir)
		velocity = velocity.move_toward(
			input_dir * max_speed,
			acceleration * delta
		)
	else:
		_update_animation(Vector2.ZERO)
		velocity = velocity.move_toward(
			Vector2.ZERO,
			deceleration * delta
		)
		
func _update_animation(dir: Vector2) -> void:
	#animated_sprite_2d.play("idle")
	
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
