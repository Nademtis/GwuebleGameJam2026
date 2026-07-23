extends Area2D
class_name PlayerWarmth

@export var max_warmth : float = 10.0

@export var warmth_restore_speed : float = 2.5
# higher = faster initial recovery

@export var warmth_loss_speed : float = 1.0
# seconds lost per second outside

var is_in_oven_heat_range : bool = false

var current_warmth : float = 0


func _ready() -> void:
	current_warmth = max_warmth

func _process(delta: float) -> void:
	print("warmth", current_warmth)
	if is_equal_approx(current_warmth, max_warmth) and is_in_oven_heat_range:
		return

	if is_in_oven_heat_range:
		restore_warmth(delta)
	else:
		lose_warmth(delta)

	if current_warmth <= 0:
		freeze()

func restore_warmth(delta: float) -> void:
	current_warmth = lerp(
		current_warmth,
		max_warmth,
		warmth_restore_speed * delta
	)

	if current_warmth > max_warmth - 0.05:
		current_warmth = max_warmth

func lose_warmth(delta: float) -> void:
	current_warmth -= warmth_loss_speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("heat"):
		is_in_oven_heat_range = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("heat"):
		is_in_oven_heat_range = false

func freeze() -> void:
	print("should restart level")
	set_process(false)
