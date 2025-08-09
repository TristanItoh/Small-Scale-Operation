extends ColorRect

@export var fade_duration: float = 1.0

signal fade_completed

func _ready():
	modulate.a = 0
	hide()

func fade_out() -> void:
	show()
	await fade(1.0)
	emit_signal("fade_completed")

func fade_in() -> void:
	show()
	fade(0.0)

func fade(target_alpha: float) -> void:
	var tween = create_tween()
	await tween.tween_property(self, "modulate:a", target_alpha, fade_duration).finished
	
	if target_alpha == 0:
		hide()
	
	
