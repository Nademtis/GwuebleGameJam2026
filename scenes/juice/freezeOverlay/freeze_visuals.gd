extends CanvasLayer
class_name FreezeVisuals

@export var player_warmth : PlayerWarmth

@onready var rect: ColorRect = $rect # material is on this colorRect
@export var visual_lerp_speed := 2.5

# 1.0 is totally warm
# 0.0 is freezing dead 
const LITTLE_FREEZE_THRESHOLD := 0.85
const MEDIUM_FREEZE_THRESHOLD := 0.6
const SEVERE_FREEZE_THRESHOLD := 0.3

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
		"darkness": 0.0
	},

	FreezeState.LITTLE: {
		"saturation": 0.38,
		"darkness": 0.1
	},

	FreezeState.MEDIUM: {
		"saturation": 0.50,
		"darkness": 0.25
	},

	FreezeState.SEVERE: {
		"saturation": 0.8,
		"darkness": 0.5
	}
}
#endregion states


func _ready() -> void:
	if not player_warmth:
		push_error("player_warmth not defined")
	

var current_saturation : float = 0.0
var current_darkness : float = 0.0

func _process(delta: float) -> void:
	var state := get_freeze_state()

	var target_values : Dictionary = STATES[state]

	current_saturation = lerp(
		current_saturation,
		target_values.saturation,
		visual_lerp_speed * delta
	)

	current_darkness = lerp(
		current_darkness,
		target_values.darkness,
		visual_lerp_speed * delta
	)

	update_shader()


func get_freeze_state() -> FreezeState:
	var warmth_percent := (
		player_warmth.current_warmth /
		player_warmth.max_warmth
	)

	print("warmth_percent: ", warmth_percent)

	if warmth_percent > LITTLE_FREEZE_THRESHOLD:
		return FreezeState.NORMAL

	if warmth_percent > MEDIUM_FREEZE_THRESHOLD:
		return FreezeState.LITTLE

	if warmth_percent > SEVERE_FREEZE_THRESHOLD:
		return FreezeState.MEDIUM

	return FreezeState.SEVERE


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
