extends CharacterBody2D
class_name Wagon

@export var player_ref : Player = null

#region movement
#each time wagon hit snow. wagon slowed down by this in 
@export var snow_speed_loss : float = 4.0

@onready var left_player_push_spot: Marker2D = $handles/leftHandle/leftPlayerPushSpot
@onready var right_player_push_spot: Marker2D = $handles/rightHandle/rightPlayerPushSpot

@onready var light_container: Node2D = $Oven/lightContainer

@onready var wheels_animated_sprite_2d_1: AnimatedSprite2D = $spriteContainer/wheelContainer/wheelsAnimatedSprite2d
@onready var wheels_animated_sprite_2d_2: AnimatedSprite2D = $spriteContainer/wheelContainer/wheelsAnimatedSprite2d2

var wheel_frame_1 := 0
var wheel_progress_1 := 0.0

var wheel_frame_2 := 0
var wheel_progress_2 := 0.0

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

#overall movement
@export var max_push_speed : float = 42.0
@export var push_acceleration : float = 16.0
@export var push_deceleration : float = 28.0


var push_speed : float = 0.0
var actual_speed : float = 0.0

#endregion movement


#region audio
#AUDIO
@export var walkable_tilemap_layer: TileMapLayer # for audio
@onready var grab_handle_random: AudioStreamPlayer = $Oven/AUDIO/GrabHandleRandom
@onready var audio_wagon_movement: AudioStreamPlayer2D = $Oven/AUDIO/MOVEMENT_SOUNDS/audioWagonMovement # syncronized

var synchronized_stream: AudioStreamSynchronized

@export var snow_override_time := 3.0
var snow_override_timer := 0.0
var current_ground_type := ""

const DIRT_STREAM := 1
const GRASS_STREAM := 2
const SNOW_STREAM := 3

@export var snow_layer_boost_db := 7.0

#var MAX_ROLLING_DB : float # grabbed from the inspector in ready
var current_rolling_db: float # changed in code

@export_category("Audio")
@export var max_rolling_db: float = 5.0
@export var min_rolling_db: float = -80.0
@export var rolling_volume_curve: Curve
@export var rolling_volume_lerp_speed := 50

const ABSOLUTE_MAX_AUDIO_DB := 20.0 # never louder than this
const WARNING_AUDIO_DB := 15.0

#endregion audio


func _ready() -> void:
	if not player_ref:
		push_error("player ref not defined")
		
	if not walkable_tilemap_layer:
		push_error("walkable_tilemap_layer not defined")
	
	#AUDIO
	if audio_wagon_movement.stream is AudioStreamSynchronized:
		synchronized_stream = audio_wagon_movement.stream
	else:
		push_error("Wagon movement audio is not AudioStreamSynchronized")
	#MAX_ROLLING_DB = audio_wagon_movement.volume_db
	
	audio_wagon_movement.volume_db = min_rolling_db
	audio_wagon_movement.play()
		
		
	light_container.visible = true
		
	randomize()
	var frame_count := wheels_animated_sprite_2d_1.sprite_frames.get_frame_count("turn")
	wheel_frame_1 = randi_range(0, frame_count - 1)
	wheel_frame_2 = randi_range(0, frame_count - 1)

	wheels_animated_sprite_2d_1.frame = wheel_frame_1
	wheels_animated_sprite_2d_2.frame = wheel_frame_2

func _physics_process(delta : float) -> void:
	#TODO remove this
	#debug_audio_counter += 1
	#if debug_audio_counter >= 10:
		#debug_audio_counter = 0
		#print_audio_debug()
	
	#print("braceProgress: ", brace_progress)
	#print("PushIntensity: ", push_intensity)
	update_wagon_audio(delta)
	update_rolling_volume(delta)
	
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
			
	anim_wheels()
			
func handle_idle() -> void:
	if player_touching_left_handle:
		if player_ref.input_dir == Vector2.RIGHT:
			start_bracing(true)

	if player_touching_right_handle:
		if player_ref.input_dir == Vector2.LEFT:
			start_bracing(false)

func start_bracing(going_right : bool) -> void:
	grab_handle_random.play()
	push_state = PushState.BRACING
	player_ref.is_pushing = true
	#player_ref.velocity = Vector2.ZERO
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

	if not player_is_still_pushing():
		push_state = PushState.SLOWING
		return

	push_speed = move_toward(
		push_speed,
		max_push_speed,
		push_acceleration * delta
	)
	push_intensity = push_speed / max_push_speed
	velocity.x = push_speed * push_direction
	var previous_position := global_position
	move_and_slide()
	actual_speed = abs(global_position.x - previous_position.x) / delta
	#print("actual speed: ", actual_speed)
	#TODO
	#use this below to impact ice block
	#var hit : int = get_slide_collision_count()
	#print("hit amount: ", hit)
	#if hit > 0:
		#for i in get_slide_collision_count():
			#var collision := get_slide_collision(i)
			#var collider := collision.get_collider()
#
			#if collider is StaticBody2D:
				#print("Wagon hit static object:", collider.name)
	
	if push_direction == 1:
		player_ref.global_position = left_player_push_spot.global_position
	else:
		player_ref.global_position = right_player_push_spot.global_position

func handle_slowing(delta : float) -> void:
	if player_ref.is_pushing:
		if not player_is_still_pushing():
			release_player()

	push_speed = move_toward(
		push_speed,
		0.0,
		push_deceleration * delta
	)
	push_intensity = push_speed / max_push_speed

	velocity.x = push_speed * push_direction
	velocity.y = 0

	var previous_position := global_position
	move_and_slide()
	actual_speed = abs(global_position.x - previous_position.x) / delta
	#print("actual speed: ", actual_speed)

	# full stop
	if push_speed <= 0.01:
		velocity = Vector2.ZERO
		push_state = PushState.IDLE

func release_player() -> void:
	#print("released with this player_ref.input_dir: ", player_ref.input_dir)
	player_ref.is_pushing = false
	player_ref.velocity = Vector2.ZERO
	brace_progress = 0.0
	#player_ref.velocity = Vector2(-push_direction * 100, 0) # fun bounce away when detaching from wagon

func player_stopped_pushing() -> void:
	player_ref.is_pushing = false

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
		return (
			player_ref.input_dir.x > 0
			and player_ref.input_dir.y == 0
		)

	else:
		return (
			player_ref.input_dir.x < 0
			and player_ref.input_dir.y == 0
		)


func anim_wheels() -> void:
	# STOPPING
	if push_state == PushState.IDLE or push_state == PushState.BRACING:
		if wheels_animated_sprite_2d_1.is_playing():
			wheel_frame_1 = wheels_animated_sprite_2d_1.frame
			wheel_progress_1 = wheels_animated_sprite_2d_1.frame_progress
			
			wheel_frame_2 = wheels_animated_sprite_2d_2.frame
			wheel_progress_2 = wheels_animated_sprite_2d_2.frame_progress

			wheels_animated_sprite_2d_1.stop()
			wheels_animated_sprite_2d_2.stop()

			# keep the last visual frame - save it for next start. Maybe this works
			wheels_animated_sprite_2d_1.set_frame_and_progress(wheel_frame_1, wheel_progress_1)
			wheels_animated_sprite_2d_2.set_frame_and_progress(wheel_frame_2, wheel_progress_2)
		return

	# STARTING MOVEMENT
	if not wheels_animated_sprite_2d_1.is_playing():
		if push_direction == 1:
			wheels_animated_sprite_2d_1.play("turn")
			wheels_animated_sprite_2d_2.play("turn")
		else:
			wheels_animated_sprite_2d_1.play_backwards("turn")
			wheels_animated_sprite_2d_2.play_backwards("turn")

		# restore from previous frame
		wheels_animated_sprite_2d_1.set_frame_and_progress(wheel_frame_1,wheel_progress_1)
		wheels_animated_sprite_2d_2.set_frame_and_progress(wheel_frame_2, wheel_progress_2)
	var speed : float = max(actual_speed / max_push_speed, 0.1)

	wheels_animated_sprite_2d_1.speed_scale = speed
	wheels_animated_sprite_2d_2.speed_scale = speed
	

#region audio
func update_wagon_audio(delta: float) -> void:

	# decrease snow override timer
	if snow_override_timer > 0:
		snow_override_timer -= delta


	var ground_type := ""


	# snow override has priority
	if snow_override_timer > 0:
		ground_type = "snow"

	else:
		ground_type = get_ground_type()


	if ground_type != current_ground_type:
		current_ground_type = ground_type
		update_wagon_audio_layer(ground_type)

func get_ground_type() -> String:

	var tile_position := walkable_tilemap_layer.local_to_map(
		global_position
	)

	var tile_data := walkable_tilemap_layer.get_cell_tile_data(tile_position)

	if tile_data == null:
		return ""

	return tile_data.get_custom_data("type")
	
func update_wagon_audio_layer(type: String) -> void:

	set_layer(DIRT_STREAM, false)
	set_layer(GRASS_STREAM, false)
	set_layer(SNOW_STREAM, false)

	match type:
		"dirt":
			set_layer(DIRT_STREAM, true)

		"grass":
			set_layer(GRASS_STREAM, true)

		"snow":
			set_layer(SNOW_STREAM, true, snow_layer_boost_db)

func set_layer(index: int, enabled: bool, enabled_db: float = 0.0) -> void:
	var db := enabled_db if enabled else -80.0
	db = get_safe_audio_db(db)

	synchronized_stream.set_sync_stream_volume(index, db)


func update_rolling_volume(delta: float) -> void:
	var speed_percent : float = clamp(
		actual_speed / max_push_speed,
		0.0,
		1.0
	)

	var volume_percent := speed_percent
	#print("volume_percent: ", volume_percent)
	if rolling_volume_curve:
		volume_percent = rolling_volume_curve.sample(speed_percent)

	var target_db : float= lerp(
		min_rolling_db,
		max_rolling_db,
		volume_percent
	)
	#print("target DB")
	target_db = get_safe_audio_db(target_db)

	audio_wagon_movement.volume_db = move_toward(
		audio_wagon_movement.volume_db,
		target_db,
		rolling_volume_lerp_speed * delta
	)


#func print_audio_debug() -> void:
	#print(
		#"--- Wagon Audio ---\n",
		#"Base: ", synchronized_stream.get_sync_stream_volume(0), " dB\n",
		#"Dirt: ", synchronized_stream.get_sync_stream_volume(1), " dB\n",
		#"Grass: ", synchronized_stream.get_sync_stream_volume(2), " dB\n",
		#"Snow: ", synchronized_stream.get_sync_stream_volume(3), " dB\n",
		#"overall db: ", audio_wagon_movement.volume_db
	#)
	
func get_safe_audio_db(value: float) -> float:
	if value > WARNING_AUDIO_DB:
		push_warning(
			"Wagon audio volume is dangerously high: " 
			+ str(value) + " dB"
		)

	return clamp(
		value,
		-80.0,
		ABSOLUTE_MAX_AUDIO_DB
	)

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


func _on_snow_hitter_hit_snow() -> void:
	#print(velocity)
	push_speed = max(push_speed - snow_speed_loss, 0.0)
	snow_override_timer = snow_override_time
	
