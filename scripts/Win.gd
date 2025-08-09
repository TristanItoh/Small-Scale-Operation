extends Node2D

@onready var tip = $Tip
const SMALL_IMPACT = preload("res://assets/smallImpact.wav")

func _ready():
	for child in tip.get_children():
		child.visible = false
	FadeEffect.fade_in()
	
	_show_children_with_delay()

func _show_children_with_delay() -> void:
	await get_tree().create_timer(1.0).timeout

	for child in tip.get_children():
		child.visible = true
		play_place_sound()
		await get_tree().create_timer(1.0).timeout

func play_place_sound():
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = SMALL_IMPACT
	add_child(audio_player)
	
	audio_player.play()
	
	audio_player.finished.connect(Callable(audio_player, "queue_free"))
