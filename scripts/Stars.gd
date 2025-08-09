extends Node

var stars = 5
const WRONG_BUZZER = preload("res://assets/Wrong Buzzer - Sound Effect.mp3")

func fail():
	stars -= .5
	play_strike_sound()

func reset_stars():
	stars = 5

func play_strike_sound():
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = WRONG_BUZZER
	add_child(audio_player)
	
	var skip_time = .5 
	audio_player.play() 
	audio_player.seek(skip_time) 
	
	audio_player.finished.connect(Callable(audio_player, "queue_free"))

