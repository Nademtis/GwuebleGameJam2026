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

#audio
@export var walkable_tilemap_layer: TileMapLayer # for audio
@onready var audio_grass_random: AudioStreamPlayer = $AUDIO/Footstep/audioGrassRandom
@onready var audio_dirt_random: AudioStreamPlayer = $AUDIO/Footstep/audioDirtRandom

@onready var snow_tall_random: AudioStreamPlayer = $AUDIO/Footstep/snowTallrandom
@onready var snow_flat_random: AudioStreamPlayer = $AUDIO/Footstep/snowFlatrandom


@export var footstep_cooldown := 0.32
var footstep_timer := 0.0 # changedf in code

#hacky illegal fix for snow
enum FootstepOverride {
	NONE,
	SNOW_TALL,
	SNOW_FLAT
}
var next_footstep_override : FootstepOverride = FootstepOverride.NONE


func _ready() -> void:
	if not walkable_tilemap_layer:
		push_error("walkable_tilemap_layer not defined")

func _physics_process(delta : float) -> void:
	snow_speed_multiplier = move_toward(
		snow_speed_multiplier,
		1.0,
		snow_recovery_speed * delta
	)
	if is_pushing:
		velocity = Vector2.ZERO
		footstep_timer = 0.1
		_update_push_animation()
		return

	if can_move:
		_movement(delta)

	move_and_slide()
	update_footsteps(delta)

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

func update_footsteps(delta: float) -> void:
	footstep_timer -= delta

	# no footsteps while pushing or standing still
	if is_pushing:
		return

	if velocity.length() < 5:
		return

	if footstep_timer > 0:
		return

	play_footstep()
	footstep_timer = footstep_cooldown

func play_footstep() -> void:

	if next_footstep_override != FootstepOverride.NONE:
		play_snow_footstep()
		next_footstep_override = FootstepOverride.NONE
		return
	
	var tile_position := walkable_tilemap_layer.local_to_map(
		global_position
	)

	var tile_data := walkable_tilemap_layer.get_cell_tile_data(tile_position)

	if tile_data == null:
		return

	var ground_type : String = tile_data.get_custom_data("type")

	match ground_type:
		"grass":
			audio_grass_random.play()
			print("playing grass")

		"dirt":
			audio_dirt_random.play()
			print("playing dirt")

		_:
			push_error("unknown ground:", ground_type)

func play_snow_footstep() -> void:
	match next_footstep_override:
		FootstepOverride.SNOW_TALL:
			snow_tall_random.play()
			print("playing tall snow")

		FootstepOverride.SNOW_FLAT:
			snow_flat_random.play()
			print("playing flat snow")
			

func _on_snow_melter_area_hit_snow_tall() -> void:
	#play tall snow sound
	snow_speed_multiplier *= snow_hit_multiplier
	snow_speed_multiplier = max(snow_speed_multiplier, 0.5)

	next_footstep_override = FootstepOverride.SNOW_TALL


func _on_snow_melter_area_hit_snow_flat() -> void:
	next_footstep_override = FootstepOverride.SNOW_FLAT
