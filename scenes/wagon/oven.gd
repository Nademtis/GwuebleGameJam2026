extends Node2D
class_name Oven

@onready var lid: Lid = $"../spriteContainer/lid"

@export var max_heat : float = 20.0

var heat : float = 0.0
var fuel_queue : Array[PickupableFuel] = []


@onready var fire_1_shaker: HorizontalShaker = $"../spriteContainer/darkBackground/fireContainer/fire1/fire1shaker"
@onready var fire_2_shaker: HorizontalShaker = $"../spriteContainer/darkBackground/fireContainer/fire2/fire2shaker"
@onready var fire_3_shaker: HorizontalShaker = $"../spriteContainer/darkBackground/fireContainer/fire3/fire3shaker"

@onready var fire_1: Sprite2D = $"../spriteContainer/darkBackground/fireContainer/fire1"
@onready var fire_2: Sprite2D = $"../spriteContainer/darkBackground/fireContainer/fire2"
@onready var fire_3: Sprite2D = $"../spriteContainer/darkBackground/fireContainer/fire3"

@export var fire_lerp_speed : float = 5.0

#fire sprites can never go below this value. that would exceed the oven
const FIRE_1_MIN_Y : float = 6.0
const FIRE_2_MIN_Y : float = 8.0
const FIRE_3_MIN_Y : float = 11.0

const FIRE_MAX_Y : float = 17.0 # when the y position of fire sprites is this. the fire is not visible

const FIRE_1_SHAKE_DISTANCE: float = 0.3
const FIRE_1_SHAKE_SPEED: float = 15.0

const FIRE_2_SHAKE_DISTANCE: float = 0.5
const FIRE_2_SHAKE_SPEED: float = 17.0

const FIRE_3_SHAKE_DISTANCE: float = 0.9
const FIRE_3_SHAKE_SPEED: float = 19.0

#lights
@onready var oven_light_1: PointLight2D = $ovenLight1
@onready var oven_light_2: PointLight2D = $ovenLight2
@onready var oven_light_3: PointLight2D = $ovenLight3


@export_group("Oven Lights")

@export var light_lerp_speed := 4.0
@export var light_1_min_energy := 0.0
@export var light_1_max_energy := 0.25
@export var light_2_min_energy := 0.0
@export var light_2_max_energy := 0.5
@export var light_3_min_energy := 0.0
@export var light_3_max_energy := 0.75
@export var light_1_min_scale := 0.7
@export var light_1_max_scale := 1.0
@export var light_2_min_scale := 0.7
@export var light_2_max_scale := 1.2
@export var light_3_min_scale := 0.7
@export var light_3_max_scale := 1.4

func _ready() -> void:
	visible = true
	heat = max_heat/2
	
	_set_fire_shaker(fire_1_shaker, FIRE_1_SHAKE_DISTANCE, FIRE_1_SHAKE_SPEED)
	_set_fire_shaker(fire_2_shaker, FIRE_2_SHAKE_DISTANCE, FIRE_2_SHAKE_SPEED)
	_set_fire_shaker(fire_3_shaker, FIRE_3_SHAKE_DISTANCE, FIRE_3_SHAKE_SPEED)
	
	fire_1_shaker.start_shaking()
	fire_2_shaker.start_shaking()
	fire_3_shaker.start_shaking()


	
func _process(delta : float) -> void:
	heat = max(heat - delta, 0.0)
	update_fire_visuals(delta)
	update_light_visuals(delta)

func update_fire_visuals(delta: float) -> void:
	#var heat_percent : float = heat / max_heat
	#print("heat: ", heat)
	update_single_fire(fire_1, FIRE_1_MIN_Y, 0.0, 0.65, delta)
	update_single_fire(fire_2, FIRE_2_MIN_Y, 0.33, 0.66, delta)
	update_single_fire(fire_3, FIRE_3_MIN_Y, 0.50, 0.95, delta)

func update_single_fire(
	fire: Sprite2D,
	min_y: float,
	start_percent: float,
	end_percent: float,
	delta: float
) -> void:
	var heat_percent := heat / max_heat
	var t := inverse_lerp(
		start_percent,
		end_percent,
		heat_percent
	)
	t = clamp(t, 0.0, 1.0)
	var target_y : float = lerp(
		FIRE_MAX_Y,
		min_y,
		t
	)
	fire.position.y = lerp(
		fire.position.y,
		target_y,
		fire_lerp_speed * delta
	)

func update_light_visuals(delta: float) -> void:
	update_single_light(
		oven_light_1,
		0.0,
		0.33,
		light_1_min_energy,
		light_1_max_energy,
		light_1_min_scale,
		light_1_max_scale,
		delta
	)

	update_single_light(
		oven_light_2,
		0.33,
		0.66,
		light_2_min_energy,
		light_2_max_energy,
		light_2_min_scale,
		light_2_max_scale,
		delta
	)

	update_single_light(
		oven_light_3,
		0.66,
		1.0,
		light_3_min_energy,
		light_3_max_energy,
		light_3_min_scale,
		light_3_max_scale,
		delta
	)

func update_single_light(
	light: PointLight2D,
	start_percent: float,
	end_percent: float,
	min_energy: float,
	max_energy: float,
	min_scale: float,
	max_scale: float,
	delta: float
) -> void:

	var heat_percent := heat / max_heat
	var t := inverse_lerp(
		start_percent,
		end_percent,
		heat_percent
	)

	t = clamp(t, 0.0, 1.0)
	
	# smoother than linear
	t = t * t * (3.0 - 2.0 * t)

	var target_energy : float = lerp(
		min_energy,
		max_energy,
		t
	)
	var target_scale : float = lerp(
		min_scale,
		max_scale,
		t
	)
	light.energy = lerp(
		light.energy,
		target_energy,
		light_lerp_speed * delta
	)
	light.texture_scale = lerp(
		light.texture_scale,
		target_scale,
		light_lerp_speed * delta
	)
	

func add_fuel(fuel : PickupableFuel) -> void:
	heat += fuel.heat
	heat = clamp(heat,0.0, max_heat)
	#print("added heat - new heat: ", heat)
	
func _set_fire_shaker(shaker : HorizontalShaker, shake_distance : float, shake_speed : float) -> void:
	shaker.shake_distance = shake_distance
	shaker.shake_speed = shake_speed
