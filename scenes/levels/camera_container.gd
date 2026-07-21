extends Node
class_name CameraContainer
@onready var p_cam: PhantomCamera2D = $Path2D/pCam

@onready var wagon: Wagon = $"../YSORT/wagon"
@export var camera_smoothing : float= 7.5

@export var bracing_curve: Curve

var SHOULD_ZOOM : bool = true
var SHOULD_SHAKE : bool = true


var original_zoom : Vector2 # when running around
var bracing_zoom : Vector2 # when bracing the wagon
var pushing_zoom : Vector2 # when pushing

var max_noise_amplitude_bracing : float = 2.0
var max_noise_frequency_bracing : float = 0.5

var max_noise_amplitude_pushing : float = 1.2
var max_noise_frequency_pushing : float = 0.4

var no_noise : float = 0.0
var no_frequency : float = 0.0

var current_amplitude : float = 0.0
var current_frequency : float = 0.0

func _ready() -> void:
	original_zoom = p_cam.zoom
	bracing_zoom = Vector2(original_zoom.x + 0.25, original_zoom.y + 0.25)
	pushing_zoom = Vector2(original_zoom.x - 0.75, original_zoom.y - 0.75)
	

func _process(delta: float) -> void:

	var target_amplitude : float= 0.0
	var target_frequency : float= 0.0
	var target_zoom : Vector2 = original_zoom


	match wagon.push_state:
		Wagon.PushState.BRACING:
			target_amplitude = max_noise_amplitude_bracing * wagon.brace_progress
			target_frequency = max_noise_frequency_bracing * wagon.brace_progress
			target_zoom = bracing_zoom

		Wagon.PushState.PUSHING:
			target_amplitude = max_noise_amplitude_pushing * wagon.push_intensity
			target_frequency = max_noise_frequency_pushing * wagon.push_intensity
			target_zoom = pushing_zoom


		Wagon.PushState.SLOWING:
			target_amplitude = max_noise_amplitude_pushing * 0.1
			target_frequency = max_noise_frequency_pushing * 0.1

	if SHOULD_SHAKE:
		current_amplitude = lerp(
			current_amplitude,
			target_amplitude,
			camera_smoothing * delta
		)

		current_frequency = lerp(
			current_frequency,
			target_frequency,
			camera_smoothing * delta
		)

		p_cam.noise.amplitude = current_amplitude
		p_cam.noise.frequency = current_frequency

	if SHOULD_ZOOM:
		p_cam.zoom = p_cam.zoom.lerp(
			target_zoom,
			camera_smoothing * delta
		)
