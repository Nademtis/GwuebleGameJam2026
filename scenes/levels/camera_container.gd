extends Node
class_name CameraContainer
@onready var p_cam: PhantomCamera2D = $Path2D/pCam

@onready var wagon: Wagon = $"../YSORT/wagon"


var original_zoom : Vector2 # when running around
var max_zoom : Vector2 # when bracing the wagon

var max_noise_amplitude_bracing : float = 10.0
var max_noise_frequency_bracing : float = 0.5

var max_noise_amplitude_pushing : float = 5.0
var max_noise_frequency_pushing : float = 0.5

var no_noise : float = 0.0
var no_frequency : float = 0.0

var current_amplitude : float = 0.0
var current_frequency : float = 0.0

func _ready() -> void:
	original_zoom = p_cam.zoom
