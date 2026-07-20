extends CharacterBody2D
class_name Wagon

@export var player_ref : Player = null
@onready var left_player_push_spot: Marker2D = $handles/leftHandle/leftPlayerPushSpot
@onready var right_player_push_spot: Marker2D = $handles/rightHandle/rightPlayerPushSpot

@onready var horizontal_shaker: HorizontalShaker = $spriteContainer/HorizontalShaker

var player_touching_left_handle : bool = false
var player_touching_right_handle : bool = false

#used for move player when starting a push
var push_target: Vector2

#for moving wagon
enum PushState {
	IDLE,
	BRACING,
	PUSHING,
	SLOWING
}

#for camera noise and zoom
var brace_progress : float = 0.0
var push_intensity : float = 0.0

var push_state : PushState = PushState.IDLE
var push_direction : int = 1 # 1right -1left

@export var max_push_speed : float = 30.0
@export var push_acceleration : float = 20.0
@export var push_deceleration : float = 25.0

var push_speed : float = 0.0

func _ready() -> void:
	if not player_ref:
		push_error("player ref not defined")

func _physics_process(delta : float) -> void:
	print("braceProgress: ", brace_progress)
	#print("PushIntensity: ", push_intensity)
	
	
	match push_state:
		PushState.IDLE:
			#print("IDLE")
			handle_idle()
		PushState.BRACING:
			#print("BRACING")
			handle_bracing(delta)
		PushState.PUSHING:
			#print("PUSHING")
			handle_pushing(delta)
		PushState.SLOWING:
			#print("SLOWING")
			handle_slowing(delta)
		

func handle_idle() -> void:
	if player_touching_left_handle:
		if player_ref.input_dir == Vector2.RIGHT:
			start_bracing(true)
	if player_touching_right_handle:
		if player_ref.input_dir == Vector2.LEFT:
			start_bracing(false)

func start_bracing(going_right : bool) -> void:
	push_state = PushState.BRACING
	player_ref.is_pushing = true
	player_ref.velocity = Vector2.ZERO
	if going_right:
		push_direction = 1
		player_ref.push_direction_is_right = true
		push_target = left_player_push_spot.global_position
	else:
		push_direction = -1
		player_ref.push_direction_is_right = false
		push_target = right_player_push_spot.global_position

func handle_pushing(delta : float) -> void:

	#stop pushing when player let go
	if push_direction == 1:
		if player_ref.input_dir != Vector2.RIGHT:
			push_state = PushState.SLOWING
			return
	else:
		if player_ref.input_dir != Vector2.LEFT:
			push_state = PushState.SLOWING
			return

	push_speed = move_toward(
		push_speed,
		max_push_speed,
		push_acceleration * delta
	)
	push_intensity = push_speed / max_push_speed

	velocity.x = push_speed * push_direction
	velocity.y = 0

	move_and_slide()

	#asign the same velocity to player
	player_ref.velocity = velocity
	player_ref.move_and_slide()

func handle_slowing(delta : float) -> void:
	if player_ref.is_pushing:
		if player_ref.input_dir != Vector2.RIGHT and push_direction == 1:
			release_player()

		if player_ref.input_dir != Vector2.LEFT and push_direction == -1:
			release_player()

	push_speed = move_toward(
		push_speed,
		0.0,
		push_deceleration * delta
	)
	push_intensity = push_speed / max_push_speed

	velocity.x = push_speed * push_direction
	velocity.y = 0

	move_and_slide()

	# only move player if still attached
	if player_ref.is_pushing:
		player_ref.velocity = velocity
		player_ref.move_and_slide()

	# full stop
	if push_speed <= 0.01:
		velocity = Vector2.ZERO
		push_state = PushState.IDLE

func release_player() -> void:
	player_ref.is_pushing = false
	player_ref.velocity = Vector2.ZERO
	brace_progress = 0.0
	#player_ref.velocity = Vector2(-push_direction * 100, 0) # fun bounce away when detaching from wagon

func player_stopped_pushing() -> void:
	print("player stopped pushing")
	#push_initiated = false
	player_ref.is_pushing = false
	#moving_to_push_position = false


func handle_bracing(delta : float) -> void:

	if not player_is_still_pushing():
		release_player()
		push_state = PushState.IDLE
		brace_progress = 0.0
		return

	var distance : float = player_ref.global_position.distance_to(push_target)
	var max_distance : float = 1 # approximate starting distance

	brace_progress = clamp(1.0 - (distance / max_distance), 0.0, 1.0)
	
	player_ref.global_position = player_ref.global_position.lerp(push_target, 5.0 * delta)
	if distance < 0.1:
		player_ref.global_position = push_target
		brace_progress = 1.0
		push_state = PushState.PUSHING

func player_is_still_pushing() -> bool:
	if push_direction == 1:
		return player_ref.input_dir == Vector2.RIGHT
	else:
		return player_ref.input_dir == Vector2.LEFT

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
