extends Area2D
class_name StormTrigger

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var label: Label = $Label

@export var new_state : StormManager.StormState = -1

var parent_storm_manager : StormManager

func _ready() -> void:
	if new_state == -1:
		push_error("new_state not defined")
		

	label.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("wagon"):
		#print("should change state")
		collision_shape_2d.set_deferred("disabled", true)
		
		parent_storm_manager = get_parent()
		parent_storm_manager.change_state(new_state)
