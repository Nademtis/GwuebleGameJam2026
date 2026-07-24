extends Node2D
class_name StormManager


@onready var black_color_rect: ColorRect = $CanvasLayer/blackColorRect

@export_group("Snow Layers")
@export var snow_layers_chill : Array[ColorRect]
@export var snow_layers_medium : Array[ColorRect]
@export var snow_layers_high : Array[ColorRect]

#the storm can have a 

func _ready() -> void:
	black_color_rect.visible = true # now it is fully black on screen
