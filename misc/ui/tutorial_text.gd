extends Area2D


@export var label : Label

@export var fade_speed: float = 5.0
var fading_in := false

func _ready() -> void:
	if not label:
		push_error("label not defined")
		
	label.modulate.a = 0.0
	label.visible = true

func _process(delta: float) -> void:
	if fading_in:
		label.modulate.a = move_toward(
			label.modulate.a,
			1.0,
			fade_speed * delta
		)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("wagon"):
		print("hit wagon")
		fading_in = true
