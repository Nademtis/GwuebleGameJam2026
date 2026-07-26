extends CanvasLayer
class_name DebugOverlay

@onready var fps_label: Label = $VBoxContainer/fpsLabel
@onready var current_storm_state: Label = $VBoxContainer/currentStormState
@onready var level_path: Label = $VBoxContainer/levelPath

var timer : float = 0.0

var show_debug : bool = false

func _ready() -> void:
	visible = show_debug
	Events.new_level_path.connect(update_level_path)
	Events.connect("storm_state_changed", update_storm_debug_text)

func _process(delta: float) -> void:
	if not show_debug:
		return
	
	timer += delta
	
	if timer >= 0.25:
		timer = 0.0
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
		
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		show_debug = !show_debug
		visible = show_debug
	if event.is_action_pressed("restart") and show_debug:
		Events.emit_signal("restart_current_level")

func update_storm_debug_text(new_storm_state : StormManager.StormState)  -> void:
	#print("new state: ", new_storm_state)
	current_storm_state.text = "StormState: " + StormManager.StormState.keys()[new_storm_state]
	
func update_level_path(path : String) -> void:
	level_path.text = path
	
