extends Node2D
class_name HorizontalShaker

@export var shake_distance: float = 3.0
@export var shake_speed: float = 15.0

var original_position: Vector2
var target_node: Node2D

var shaking: bool = false
var shake_time_left: float = 0.0


func _ready() -> void:
	target_node = get_parent()
	original_position = target_node.position

func _process(delta: float) -> void:
	if not shaking:
		return

	shake_time_left -= delta
	if shake_time_left <= 0:
		stop_shaking()
		return

	var offset : float = sin(Time.get_ticks_msec() * 0.001 * shake_speed) * shake_distance
	target_node.position.x = original_position.x + offset


func start_shaking() -> void:
	if not target_node:
		return
	
	shaking = true
	shake_time_left = INF


func stop_shaking() -> void:
	if not target_node:
		return

	shaking = false
	shake_time_left = 0

	var tween : Tween = create_tween()
	tween.tween_property(
		target_node,
		"position",
		original_position,
		0.1
	)


func shake_for_time(duration: float) -> void:
	start_shaking()
	shake_time_left = duration
