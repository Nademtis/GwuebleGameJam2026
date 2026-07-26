extends Area2D
class_name PlayerWarmth

@export var max_warmth : float = 10.0

@export var warmth_restore_speed : float = 2.5
# higher = faster initial recovery

@export var warmth_loss_speed : float = 1.0
# seconds lost per second outside

var is_in_oven_heat_range : bool = false

var current_warmth : float = 0

#juice
@export var freeze_grace_period: float = 1.25
var freeze_timer: float = 0.0

var storm_state_is_none : bool = false # nofreezing


func _ready() -> void:
	current_warmth = max_warmth
	Events.connect("storm_state_changed", check_storm_state)

func _process(delta: float) -> void:
	if is_equal_approx(current_warmth, max_warmth) and is_in_oven_heat_range:
		return
		
	#only if storm state is none. no freezing here
	if storm_state_is_none:
		restore_warmth(delta)
		return
		
	
	#print("freeze timer: ", freeze_timer)
	if is_in_oven_heat_range:
		restore_warmth(delta)
	else:
		lose_warmth(delta)

	if current_warmth <= 0:
		freeze_timer += delta
		
		if freeze_timer >= freeze_grace_period:
			freeze()
	else:
		freeze_timer = 0.0

func restore_warmth(delta: float) -> void:
	current_warmth = lerp(
		current_warmth,
		max_warmth,
		warmth_restore_speed * delta
	)

	if current_warmth > max_warmth - 0.2:
		current_warmth = max_warmth

func lose_warmth(delta: float) -> void:
	current_warmth -= warmth_loss_speed * delta


func check_storm_state(storm_state : StormManager.StormState) -> void:
	#print("from player heat: ", storm_state)
	if storm_state == StormManager.StormState.NONE:
		storm_state_is_none = true
	else:
		storm_state_is_none = false
		
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("heat"):
		is_in_oven_heat_range = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("heat"):
		is_in_oven_heat_range = false

func freeze() -> void:
	print("should restart level")
	Events.emit_signal("restart_current_level")
	set_process(false)
