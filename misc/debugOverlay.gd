extends CanvasLayer
@onready var fps_label: Label = $fpsLabel

var timer : float = 0.0

var show_debug : bool = true

func _ready() -> void:
	visible = show_debug

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
