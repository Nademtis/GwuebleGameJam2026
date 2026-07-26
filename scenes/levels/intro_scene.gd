extends Node2D

@onready var label_1: Label = $CanvasLayer/Control/VBoxContainer/Label
@onready var label_2: Label = $CanvasLayer/Control/VBoxContainer/Label2
@onready var label_3: Label = $CanvasLayer/Control/VBoxContainer/Label3

@onready var label_4: Label = $CanvasLayer/Control/VBoxContainer/Label4


@export var fade_duration := 1.0

@export_group("Label Delays")
@export var label_1_delay := 1.0
@export var label_2_delay := 1.0
@export var label_3_delay := 1.0
@export var label_4_delay := 2.5

@export var level_change_delay := 5.0

func _ready() -> void:
	label_1.modulate.a = 0.0
	label_2.modulate.a = 0.0
	label_3.modulate.a = 0.0
	label_4.modulate.a = 0.0
	
	Events.storm_state_changed.emit(StormManager.StormState.NONE)
	
	start_intro_sequence()

func start_intro_sequence() -> void:
	await show_label(label_1, label_1_delay)
	await show_label(label_2, label_2_delay)
	await show_label(label_3, label_3_delay)
	await show_label(label_4, label_4_delay)

	await get_tree().create_timer(level_change_delay).timeout
	
	Events.load_new_level.emit()


func show_label(label: Label, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	
	label.visible = true
	
	var tween := create_tween()
	tween.tween_property(
		label,
		"modulate:a",
		1.0,
		fade_duration
	)
	
	await tween.finished
