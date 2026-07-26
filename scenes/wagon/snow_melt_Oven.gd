extends Area2D
class_name SnowMelterOven

@onready var audio_snow_melting: AudioStreamPlayer = $audioSnowMelting

@export_group("Snow Melting Audio")
@export var min_volume_db := -60.0
@export var max_volume_db := 7.0
@export var volume_lerp_speed := 85.0

@export var melt_energy_per_hit := 0.13
@export var melt_energy_decay_speed := 1.38

var melt_energy := 0.0

func _ready() -> void:
	audio_snow_melting.volume_db = min_volume_db
	audio_snow_melting.play()

func _process(delta: float) -> void:
	melt_energy = move_toward(
		melt_energy,
		0.0,
		melt_energy_decay_speed * delta
	)

	var target_db : float = lerp(
		min_volume_db,
		max_volume_db,
		melt_energy
	)

	audio_snow_melting.volume_db = move_toward(
		audio_snow_melting.volume_db,
		target_db,
		volume_lerp_speed * delta
	)
	print("snow melting playing with: ", audio_snow_melting.volume_db)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("snow"):
			#print("hit snow")
			var snow : SnowBlob = area.get_parent()
			snow.melt_oven(1)
			
			melt_energy = clamp(
			melt_energy + melt_energy_per_hit,
			0.0,
			1.0
		)
