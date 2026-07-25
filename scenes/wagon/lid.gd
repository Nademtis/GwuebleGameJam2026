extends AnimatedSprite2D
class_name Lid

@onready var audio_lid_open_random: AudioStreamPlayer2D = $"../../Oven/AUDIO/audioLidOpenRandom"
@onready var audio_lid_close_random: AudioStreamPlayer2D = $"../../Oven/AUDIO/audioLidCloseRandom"


func open() -> void:
		play("open")
		audio_lid_open_random.play()
	
func close() -> void:
		play("close")
		audio_lid_close_random.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
		#open_lid()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
		#play("close")
