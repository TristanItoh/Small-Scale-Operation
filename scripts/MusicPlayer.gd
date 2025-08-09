extends Node

var music_player: AudioStreamPlayer = null
var is_playing = false

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	var music = preload("res://assets/Six Seasons.mp3")
	music_player.stream = music

	if music is AudioStream:
		music.loop = true

	music_player.volume_db = -10.0

	play_music()

func play_music():
	if not is_playing:
		music_player.play()
		is_playing = true

func pause_music():
	if is_playing:
		music_player.stop()
		is_playing = false

func toggle_music():
	if is_playing:
		pause_music()
	else:
		play_music()
