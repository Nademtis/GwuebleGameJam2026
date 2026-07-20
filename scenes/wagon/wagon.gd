extends CharacterBody2D
class_name Wagon

@export var player_ref : Player = null
@onready var left_handle: Area2D = $handles/leftHandle
@onready var left_handle_collsion_shape: CollisionShape2D = $handles/leftHandle/leftHandleCollsionShape
@onready var left_player_push_spot: Marker2D = $handles/leftHandle/leftPlayerPushSpot

var player_touching_left_handle : bool = false
var player_touching_right_handle : bool = false

var is_pushing : bool = false
var push_initiated : bool = false

func _ready() -> void:
	if not player_ref:
		push_error("player ref not defined")

func _process(delta: float) -> void:
	
	#if player is close to left handle AND is moving right
	if player_touching_left_handle:
		if player_ref.input_dir.x > 0.1:		#going right
			if not push_initiated:				#only do this once
				player_started_pushing(true)
			pushing()
		else:
			player_stopped_pushing()

func player_started_pushing(going_right : bool) -> void:
	player_ref.is_pushing = true
	player_ref.velocity = Vector2.ZERO
	push_initiated = true
	
	if going_right:
		print("connected and going right")
		player_ref.push_direction_is_right = true
	else: #going left
		print("connected and going left")
		player_ref.push_direction_is_right = false
	

func pushing() -> void:
	print("wagon is moving")

func player_stopped_pushing() -> void:
	print("player stopped pushing")
	push_initiated = false
	#reset player
	player_ref.is_pushing = false

	

func _on_left_handle_body_entered(body: Node2D) -> void:
	#player is close to left handle
	if body.is_in_group("player"):
		player_touching_left_handle = true
		#print("player hit left handle")

func _on_left_handle_body_exited(body: Node2D) -> void:
	#player is away from left handle
	if body.is_in_group("player"):
		player_touching_left_handle = false
		player_stopped_pushing()

func _on_right_handle_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_touching_right_handle = true

func _on_right_handle_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_touching_right_handle = false
