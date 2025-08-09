extends Node2D

@onready var animation_player = $PouringFlask/AnimationPlayer
@onready var color_rect = $MainFlask/ColorRect
@onready var decor_rect = $PouringFlask/ColorRect
@onready var mark = $MainFlask/Mark
@onready var timer = $MainFlask/Timer
@onready var strike = $"Strike"
@onready var success = $Success
@onready var pouring_flask = $PouringFlask
@onready var tip = $Tip

const SMALL_IMPACT = preload("res://assets/smallImpact.wav")

var started = false
var growing = false
var growth_speed = 150
var win_delay = 2.0
var max_height = 410
var successful_stops = 0
var required_stops = 3

func _ready():
	animation_player.animation_finished.connect(_on_animation_finished)
	setMarkPos()
	set_random_bright_color()
	FadeEffect.fade_in()
	
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true 
	
	if GameState.difficulty == 2:
		growth_speed = 200
	elif GameState.difficulty == 3:
		growth_speed = 275
	elif GameState.difficulty == 4:
		growth_speed = 300
	elif GameState.difficulty == 5:
		growth_speed = 350

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			print("Left mouse button clicked!")
			tip.visible = false
			if not started:
				play_animation()
				started = true
			elif growing == true:
				growing = false
				check_height_relative_to_mark()
				play_impact_sound()

func play_animation():
	var animation_name = "pour"
	if animation_player.has_animation(animation_name):
		pouring_flask.visible = true
		animation_player.play(animation_name)
	else:
		print("Animation not found: ", animation_name)

func _on_animation_finished(anim_name: String):
	if anim_name == "pour":
		growing = true
	elif anim_name == "switch_color":
		set_random_bright_color()
		play_animation()

func _process(delta: float):
	if growing:
		color_rect.size.y += growth_speed * delta
		decor_rect.size.y -= growth_speed * delta
		
		if color_rect.size.y > max_height:
			trigger_fail_condition()

func check_height_relative_to_mark():
	var mark_height = mark.global_position.y
	var current_height = color_rect.size.y
	var lower_bound = -mark_height + 492
	var upper_bound = -mark_height + 492 + 37
	
	if lower_bound <= current_height and upper_bound >= current_height:
		start_intermission()
	else:
		trigger_fail_condition()

func set_random_bright_color():
	var min_brightness = 0.5
	var r = randf()
	var g = randf()
	var b = randf()

	var brightness = max(r, g, b)
	if brightness < min_brightness:
		r += (min_brightness - brightness) * 1.5
		g += (min_brightness - brightness) * 1.5
		b += (min_brightness - brightness) * 1.5

	r = clamp(r, 0, 1)
	g = clamp(g, 0, 1)
	b = clamp(b, 0, 1)

	var bright_color = Color(r, g, b)
	color_rect.color = bright_color
	decor_rect.color = bright_color

func start_win_sequence():
	print("You Win!")
	GameState.next_station()
	timer.start(win_delay)
	
	success.visible = true
	const success_sound = preload("res://assets/success_sound.mp3")
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = success_sound
	audio_player.volume_db = 10
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(Callable(audio_player, "queue_free"))

func _on_timer_timeout():
	await FadeEffect.fade_out()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func trigger_fail_condition():
	print("You Lose!")
	growing = false
	Stars.fail()

	if strike != null:
		strike.visible = true
	else:
		print("Strike node not found!")
		
	timer.start(win_delay)

func start_intermission():
	var animation_name = "switch_color"
	if animation_player.has_animation(animation_name):
		pouring_flask.visible = true
		successful_stops += 1
		if successful_stops < required_stops:
			setMarkPos()
			animation_player.play(animation_name)
		else:
			start_win_sequence()
	else:
		print("Animation not found: ", animation_name)

func setMarkPos():
	var min_y = 150

	if successful_stops == 0:
		mark.global_position.y = randf_range(300, 400)
	elif successful_stops == 1:
		var new_min_y = max(min_y, mark.global_position.y - 100)
		mark.global_position.y = randf_range(new_min_y, mark.global_position.y - 50)
	elif successful_stops == 2:
		var new_min_y = max(min_y, mark.global_position.y - 100)
		mark.global_position.y = randf_range(new_min_y, mark.global_position.y - 50)

func play_impact_sound():
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = SMALL_IMPACT
	add_child(audio_player)
	
	audio_player.play()
	
	audio_player.finished.connect(Callable(audio_player, "queue_free"))
