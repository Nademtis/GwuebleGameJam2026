extends Node2D
#main

@onready var level_container: Node2D = $LevelContainer

#todo
@onready var focus_menu: CanvasLayer = $FocusMenu

@onready var animation_player: AnimationPlayer = $fadeInOut/AnimationPlayer

@onready var music_loop_intro_levels: AudioStreamPlayer = $AudioManager/music_loop_intro_levels
@onready var music_epic_theme: AudioStreamPlayer = $AudioManager/music_epic_theme

@export_group("Music Fade In")
@export var music_fade_duration := 4.0
@export var music_start_db := -40.0
@export var music_target_db := 0.0

var level_list : Array[String] = [
	"res://scenes/levels/intro_scene.tscn",
	"res://scenes/levels/level_1.tscn", 
	"res://scenes/levels/level_2.tscn", 
	"res://scenes/levels/level_3.tscn", #chill --> freeze start
	"res://scenes/levels/level_4.tscn", #medium halvt inde
	"res://scenes/levels/level_5.tscn", # should be medium --> with 1 ice
	"res://scenes/levels/level_6.tscn", # should be high --> with 1 ice
	"res://scenes/levels/end_screen.tscn",#"thanks for playing" "more snow??"
]

var level_index : int = 0 # start with 0
var next_level_path: String
var current_level_path: String

func _ready() -> void:
	#TODO focusmenu
	get_window().focus_entered.connect(_on_window_focus_entered)
	get_window().focus_exited.connect(_on_window_focus_exited)
	focus_menu.visible = false
	
	Events.connect("load_new_level", start_new_level.bind(false))
	Events.connect("restart_current_level" , restart_level)

	next_level_path = level_list[level_index]
	await _setup_new_level()

func start_new_level(to_restart : bool) -> void:
	if not to_restart:
		level_index += 1 
		
	print("main booting level: ", level_index)
	next_level_path = level_list[level_index]
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	await _setup_new_level()
	#fade_out_sfx.play() # #todo

func _setup_new_level() -> void:
	for child : Node in level_container.get_children():
		child.queue_free()

	var level_scene: PackedScene = load(next_level_path) as PackedScene
	if not level_scene:
		push_error("Failed to load level: " + next_level_path)
		return

	var new_level_scene : PackedScene = load(next_level_path)
	var new_level_instance : Node2D = new_level_scene.instantiate()
	level_container.add_child(new_level_instance)
	
	animation_player.play("fade_out")
	
	var level_name : String = next_level_path.get_file().get_basename()
	Events.new_level_path.emit(level_name) # for debug
	
	if level_name == "level_1":
		if not music_loop_intro_levels.playing:
			fade_in_audio(music_loop_intro_levels)
			print_debug("started intro song")
	
	if level_name == "level_6":
		music_loop_intro_levels.stop()

		if not music_epic_theme.playing:
			fade_in_audio(music_epic_theme)
			print_debug("started epic theme")
	
	#fade_in_sfx.play() # level start
	if level_index == 0:
		await get_tree().create_timer(1).timeout


func restart_level() -> void:
	await start_new_level(true)

func remove_active_cam() -> void:
	var list : Array[PhantomCamera2D] = PhantomCameraManager.get_phantom_camera_2ds()
	if list:
		for cam : PhantomCamera2D in list:
			cam.priority = 0
			

func fade_in_audio(audio: AudioStreamPlayer) -> void:
	audio.volume_db = music_start_db
	audio.play()

	var tween := create_tween()
	tween.tween_property(
		audio,
		"volume_db",
		music_target_db,
		music_fade_duration
	).set_trans(Tween.TRANS_LINEAR)

func _on_window_focus_entered() -> void:
	focus_menu.visible = false
func _on_window_focus_exited() -> void:
	focus_menu.visible = true
