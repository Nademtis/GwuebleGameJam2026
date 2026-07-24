extends Node2D
class_name StormManager


@onready var freeze_shader: ColorRect = $"../Node2D/SnowDustShaderGoingLeft/freezeShader" # has ice_lens shader

@export var init_storm_state : StormState 

@export_group("Snow Layers")
@export var snow_layers_chill : Array[ColorRect]
@export var snow_layers_medium : Array[ColorRect]
@export var snow_layers_high : Array[ColorRect]

@export_group("Transition")
@export var storm_lerp_speed := 0.8

@export_group("Black Flash")
@export var flash_duration : float = 0.15
@export var flash_pause : float = 0.4
@export var flash_amount : float = 0.8
@export var flash_count : int = 3

enum StormState{
	CHILL,
	MEDIUM,
	HIGH}

const STATES = {
	StormState.CHILL:
	{
		"snow_layers": "chill",
		"freeze_amount": 0.5,
		"distortion_strength": 0.0,
		"storm_intensity": 0.25
	},

	StormState.MEDIUM:
	{
		"snow_layers": "medium",
		"freeze_amount": 0.78,
		"distortion_strength": 0.0,
		"storm_intensity": 0.6
	},

	StormState.HIGH:
	{
		"snow_layers": "high",
		"freeze_amount": 1.0,
		"distortion_strength": 0.01,
		"storm_intensity": 1.0
	}
}

var current_state : StormState = StormState.CHILL
var storm_intensity := 0.0
var freeze_material : ShaderMaterial

func _ready() -> void:

	freeze_material = freeze_shader.material as ShaderMaterial

	apply_state(init_storm_state)
	
func change_state(new_state: StormState) -> void:
	if current_state == new_state:
		return

	current_state = new_state

	apply_state(new_state)
	
		
func apply_state(state: StormState) -> void:
	var values:Dictionary = STATES[state]
	storm_intensity = values["storm_intensity"]

	update_snow_layers(values["snow_layers"])
	update_freeze_shader(values)
	
func update_snow_layers(layer_name: String) -> void:

	hide_layers(snow_layers_chill)
	hide_layers(snow_layers_medium)
	hide_layers(snow_layers_high)

	match layer_name:
		"chill":
			show_layers(snow_layers_chill)
		"medium":
			show_layers(snow_layers_medium)
		"high":
			show_layers(snow_layers_high)


func hide_layers(layers:Array[ColorRect]) -> void:
	for layer in layers:
		layer.visible = false

func show_layers(layers:Array[ColorRect]) -> void:
	for layer in layers:
		layer.visible = true
		
func update_freeze_shader(values:Dictionary) -> void:
	var target_freeze: float = values["freeze_amount"]
	var target_distortion: float = values["distortion_strength"]

	var duration := 1.0 / storm_lerp_speed

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_method(
		set_freeze_amount,
		get_freeze_amount(),
		target_freeze,
		duration
	)

	tween.tween_method(
		set_distortion,
		get_distortion(),
		target_distortion,
		duration
	)


func set_freeze_amount(value: float) -> void:
	freeze_material.set_shader_parameter("freeze_amount", value)

func set_distortion(value: float) -> void:
	freeze_material.set_shader_parameter("distortion_strength", value)
	

	
func get_freeze_amount() -> float:
	return freeze_material.get_shader_parameter("freeze_amount")


func get_distortion() -> float:
	return freeze_material.get_shader_parameter("distortion_strength")
