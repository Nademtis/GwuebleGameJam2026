extends CharacterBody2D
class_name Wagon

@export var player_ref : Player = null
@onready var left_player_push_spot: Marker2D = $handles/leftHandle/leftPlayerPushSpot
@onready var right_player_push_spot: Marker2D = $handles/rightHandle/rightPlayerPushSpot

var player_touching_left_handle : bool = false
var player_touching_right_handle : bool = false

var is_pushing : bool = false
var push_initiated : bool = false

#used for move player when starting a push
var push_target: Vector2
var moving_to_push_position: bool = false

func _ready() -> void:
	if not player_ref:
		push_error("player ref not defined")

func _process(delta: float) -> void:
	if moving_to_push_position:
		handle_player_nudging_when_starting_push(delta)
	
	if player_touching_left_handle:
		if player_ref.input_dir.x > 0.5 and player_ref.input_dir.y == 0.0: #going right and only pressing right
			if not push_initiated: #only this once
				player_started_pushing(true)
			pushing()
		else:
			player_stopped_pushing()
	
	if player_touching_right_handle:
		print(player_ref.input_dir)
		if player_ref.input_dir.x < -0.5 and player_ref.input_dir.y == 0.0: #going left and only pressing left
			if not push_initiated: #only this once
				player_started_pushing(false)
			pushing()
		else:
			player_stopped_pushing()
		
	
func player_started_pushing(going_right : bool) -> void:
	player_ref.is_pushing = true
	player_ref.velocity = Vector2.ZERO
	push_initiated = true
	moving_to_push_position = true
	
	if going_right:
		print("connected and going right")
		player_ref.push_direction_is_right = true
		push_target = left_player_push_spot.global_position
	else: #going left
		print("connected and going left")
		player_ref.push_direction_is_right = false
		push_target = right_player_push_spot.global_position
	
	

func pushing() -> void:
	print("wagon is moving")

func player_stopped_pushing() -> void:
	print("player stopped pushing")
	push_initiated = false
	player_ref.is_pushing = false
	moving_to_push_position = false


func handle_player_nudging_when_starting_push(delta : float) -> void:
	player_ref.global_position = player_ref.global_position.lerp(push_target, 5.0 * delta)
	
	if player_ref.global_position.distance_to(push_target) < 0.1:
		player_ref.global_position = push_target
		moving_to_push_position = false


func _on_left_handle_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_touching_left_handle = true

func _on_left_handle_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_touching_left_handle = false
		player_stopped_pushing()

func _on_right_handle_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_touching_right_handle = true

func _on_right_handle_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_touching_right_handle = false
		player_stopped_pushing()
