extends TileMapLayer
class_name SnowManager


@export var player: Player

@export var process_distance: float = 500.0
@export var snow_check_interval: float = 5.0


var snow_blobs: Array[SnowBlob] = []
var check_timer := 0.0

func _ready() -> void:

	if not player:
		push_error("SnowManager: Player missing")
		
	await get_tree().process_frame
	
	for child in get_children():
		if child is SnowBlob:
			snow_blobs.append(child)

func _process(delta: float) -> void:
	check_timer -= delta

	if check_timer <= 0:
		check_timer = snow_check_interval
		update_snow_activity()

func update_snow_activity() -> void:

	var max_distance_squared := process_distance * process_distance
	var player_position := player.global_position

	for snow in snow_blobs:
		var active := (
			snow.global_position.distance_squared_to(player_position)
			< max_distance_squared
		)
		snow.meltbox.disabled = not active

		if active:
			snow.start_melting()
		else:
			snow.set_process(false)
