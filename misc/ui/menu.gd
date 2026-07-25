extends Control
class_name Menu

var showing_menu : bool = false

const MASTER_BUS_NAME : String = "player_master"
const MUSIC_BUS_NAME : String = "player_music"
const SFX_BUS_NAME : String = "player_sfx"
const AMBIENCE_BUS_NAME : String = "player_ambience"

@onready var master_slider: HSlider = $CenterContainer/VBoxContainer2/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $CenterContainer/VBoxContainer2/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/VBoxContainer2/VBoxContainer/SFXSlider
@onready var ambience_slider: HSlider = $CenterContainer/VBoxContainer2/VBoxContainer/AmbienceSlider


func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		menu()

func menu() -> void:
	showing_menu = !showing_menu
	if showing_menu:
		visible = true
		#menu_controller.play_menu_sfx(true)
	else:
		visible = false
		#menu_controller.play_menu_sfx(false)




func _on_restart_level_button_button_down() -> void:
	Events.emit_signal("restart_current_level")
	menu()


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS_NAME), linear_to_db(value))


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS_NAME), linear_to_db(value))



func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS_NAME), linear_to_db(value))
	
	pass # Replace with function body.


func _on_ambience_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AMBIENCE_BUS_NAME), linear_to_db(value))
	pass # Replace with function body.
