extends Node2D

@onready var countdown_timer = $CountdownTimer
var countdown_time = 40.0
@onready var strike = $"Strike"
@onready var results_timer = $ResultsTimer
@onready var success = $Success
var results_delay = 2.0
var finished = false
@onready var tip = $Tip
var waiting_for_click = true

func _ready():
	countdown_timer.wait_time = 0.1
	countdown_timer.one_shot = false
	GlobalPackingManager.correct_count = 0
	countdown_timer.stop()
	FadeEffect.fade_in()

	$Bag1.connect("wrong_piece_placed", Callable(self, "_on_wrong_piece_placed"))
	$Bag2.connect("wrong_piece_placed", Callable(self, "_on_wrong_piece_placed"))
	$Bag3.connect("wrong_piece_placed", Callable(self, "_on_wrong_piece_placed"))
	$Bag4.connect("wrong_piece_placed", Callable(self, "_on_wrong_piece_placed"))
	
	results_timer.timeout.connect(_on_results_timer_timeout)
	results_timer.one_shot = true 
	
	if GameState.difficulty == 2:
		countdown_time = 35
	elif GameState.difficulty == 3:
		countdown_time = 31
	elif GameState.difficulty == 4:
		countdown_time = 27
	elif GameState.difficulty == 5:
		countdown_time = 22
		
	$CountdownLabel.text = "%.1f" % countdown_time

	set_process_input(true)

func _process(delta):
	if GlobalPackingManager.correct_count == 12 and not finished:
		start_win_sequence()

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and waiting_for_click:
			waiting_for_click = false
			countdown_timer.start()
			tip.visible = false

func _on_countdown_timer_timeout():
	if not finished:
		countdown_time -= 0.1
		
		if countdown_time <= 0:
			countdown_time = 0
			update_timer_display()
			_handle_timer_end()
		else:
			update_timer_display()

func update_timer_display():
	$CountdownLabel.text = "%.1f" % countdown_time

func start_win_sequence():
	finished = true
	$CountdownLabel.text = ""
	GameState.next_station()
	results_timer.start(results_delay)
	print(results_timer.time_left)
	
	success.visible = true
	const success_sound = preload("res://assets/success_sound.mp3")
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = success_sound
	audio_player.volume_db = 10
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(Callable(audio_player, "queue_free"))
	
func start_lose_sequence():
	finished = true
	Stars.fail()
	$CountdownLabel.text = ""

	if strike != null:
		strike.visible = true
	else:
		print("Strike node not found!")

	results_timer.start(results_delay)

func _handle_timer_end():
	start_lose_sequence()
	
func _on_wrong_piece_placed():
	start_lose_sequence()
	
func _on_results_timer_timeout():
	await FadeEffect.fade_out()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
