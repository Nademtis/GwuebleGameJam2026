extends CanvasLayer
class_name FreezeVisuals

@export var player_warmth : PlayerWarmth

@onready var rect: ColorRect = $rect # material is on this colorRect
@export var visual_lerp_speed := 2.5

@onready var freeze_overlay: ColorRect = $CanvasLayer/freezeOverlay

#when severe this radial thing chases the player
@export var radial_freeze_speed := 0.1 # slow closing
@export var radial_recover_speed := 1.1 # fast opening

@onready var severe_radial_sloop: ColorRect = $vignette/severeRadialSloop
var current_circle_center := Vector2(0.5,0.5)
var current_circle_radius := 1.2
var target_circle_radius := 1.2

# 1.0 is totally warm
# 0.0 is freezing dead 
const LITTLE_FREEZE_THRESHOLD := 0.85
const MEDIUM_FREEZE_THRESHOLD := 0.6
const SEVERE_FREEZE_THRESHOLD := 0.3

const MAX_DISTORTION_STRENGTH := 0.04
const MAX_FREEZE_AMOUNT := 1.0

#changed runtime
var current_saturation := 0.0
var current_darkness := 0.0
var current_distortion := 0.0
var current_freeze_amount := 0.0

#region states
enum FreezeState {
	NORMAL,
	LITTLE,
	MEDIUM,
	SEVERE
}
const STATES = {
	FreezeState.NORMAL: {
		"saturation": 0.0,
		"darkness": 0.0,
		"distortion": 0.0,
		"freeze_amount": 0.0,
		"circle_radius": 1.2
	},

	FreezeState.LITTLE: {
		"saturation": 0.38,
		"darkness": 0.1,
		"distortion": 0.00,
		"freeze_amount": 0.2,
		"circle_radius": 0.6
	},

	FreezeState.MEDIUM: {
		"saturation": 0.50,
		"darkness": 0.25,
		"distortion": 0.01,
		"freeze_amount": 0.45,
		"circle_radius": 0.48
	},

	FreezeState.SEVERE: {
		"saturation": 0.8,
		"darkness": 0.5,
		"distortion": 0.02,
		"freeze_amount": 0.65,
		"circle_radius": 0.2
	}
}
#endregion states


func _ready() -> void:
	if not player_warmth:
		push_error("player_warmth not defined")
	
	current_circle_radius = 1.2


func _process(delta: float) -> void:
	var state := get_freeze_state()
	var target_values: Dictionary = STATES[state]

	current_saturation = lerp(
		current_saturation,
		target_values["saturation"],
		visual_lerp_speed * delta
	)

	current_darkness = lerp(
		current_darkness,
		target_values["darkness"],
		visual_lerp_speed * delta
	)

	current_distortion = lerp(
		current_distortion,
		target_values["distortion"],
		visual_lerp_speed * delta
	)

	current_freeze_amount = lerp(
		current_freeze_amount,
		target_values["freeze_amount"],
		visual_lerp_speed * delta
	)
	target_circle_radius = target_values["circle_radius"]

	update_radial_radius(delta)
	
	update_radial_shader()
	update_color_shader()
	update_freeze_overlay()


func get_freeze_state() -> FreezeState:
	var warmth_percent := (
		player_warmth.current_warmth /
		player_warmth.max_warmth
	)

	#print("warmth_percent: ", warmth_percent)

	if warmth_percent > LITTLE_FREEZE_THRESHOLD:
		return FreezeState.NORMAL

	if warmth_percent > MEDIUM_FREEZE_THRESHOLD:
		return FreezeState.LITTLE

	if warmth_percent > SEVERE_FREEZE_THRESHOLD:
		return FreezeState.MEDIUM

	return FreezeState.SEVERE

func update_color_shader() -> void:
	var material := rect.material as ShaderMaterial

	material.set_shader_parameter(
		"desaturation",
		current_saturation
	)

	material.set_shader_parameter(
		"darkness",
		current_darkness
	)


func update_freeze_overlay() -> void:
	var material := freeze_overlay.material as ShaderMaterial

	material.set_shader_parameter(
		"distortion_strength",
		current_distortion * MAX_DISTORTION_STRENGTH
	)

	material.set_shader_parameter(
		"freeze_amount",
		current_freeze_amount * MAX_FREEZE_AMOUNT
	)

func update_shader() -> void:
	var material := rect.material as ShaderMaterial

	material.set_shader_parameter(
		"desaturation",
		current_saturation
	)

	material.set_shader_parameter(
		"darkness",
		current_darkness
	)
	
func update_radial_shader() -> void:
	var material := severe_radial_sloop.material as ShaderMaterial

	material.set_shader_parameter(
		"circle_radius",
		current_circle_radius
	)

	var player_screen_position := get_viewport().get_camera_2d().get_screen_center_position()

func update_radial_radius(delta: float) -> void:
	if current_circle_radius > target_circle_radius:
		# freezing: slowly close in
		current_circle_radius = move_toward(
			current_circle_radius,
			target_circle_radius,
			radial_freeze_speed * delta
		)
	else:
		# recovering: quickly open
		current_circle_radius = move_toward(
			current_circle_radius,
			target_circle_radius,
			radial_recover_speed * delta
		)
