extends Node2D

@onready var label_1: Label = $CanvasLayer/Control/VBoxContainer/Label
@onready var label_2: Label = $CanvasLayer/Control/VBoxContainer/Label2
@onready var label_3: Label = $CanvasLayer/Control/VBoxContainer/Label3



var timer_level_change: float = 10.0
var current_timer_level_change: float 


func _ready() -> void:
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	
	Events.storm_state_changed.emit(StormManager.StormState.NONE)
