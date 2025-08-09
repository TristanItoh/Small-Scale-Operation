extends Node2D

const POSITIONS = [356, 502, 653, 798]
const CACTUSPOSITIONS = [4, 158, 863, 1023]
const CAR_SCENE = preload("res://scenes/car.tscn")
const CACTUS = preload("res://scenes/Cactus.tscn")
@onready var back1 = $Back1
@onready var back2 = $Back2
const SPAWN_Y = -110
const SCROLL_SPEED = 1000
const BACKGROUND_HEIGHT = 649 
const CAR_SPAWN_DELAY = 2.0
var countdown_finished = false
var car_spawning_enabled = true 
var maxCarRate = 1.3

@onready var countdown_timer = $CountdownTimer
@onready var countdown_label = $CountdownLabel
@onready var strike = $"Strike"
@onready var tip = $Tip
var countdown_time = 20.0  
const INITIAL_COUNTDOWN_TIME = 20.0  

var time_since_last_spawn = 0.0
var time_since_last_cactus = 0.0
var time_since_start = 0.0

var car_spawn_interval = 1.0 
var cactus_spawn_interval = 0.5 

var game_started = false  

const DISPLAY_TEXT_START = 100.0
const DISPLAY_TEXT_END = 0.0

func _ready():
	FadeEffect.fade_in()
	if GameState.difficulty == 2:
		countdown_time = 30
		maxCarRate = 1.2
	elif GameState.difficulty == 3:
		countdown_time = 35
		maxCarRate = 1.1
	elif GameState.difficulty == 4:
		countdown_time = 40
		maxCarRate = 1.0
	elif GameState.difficulty == 5:
		countdown_time = 45
		maxCarRate = 0.9
		
	time_since_last_spawn = car_spawn_interval  
	time_since_last_cactus = cactus_spawn_interval 
	time_since_start = 0.0 
	
	back1.position = Vector2(0, 0)
	back2.position = Vector2(0, -BACKGROUND_HEIGHT) 
	
	countdown_timer.wait_time = 0.1  
	countdown_timer.one_shot = false  
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)
	countdown_label.text = "%.1f" % str((countdown_time / INITIAL_COUNTDOWN_TIME) * 100)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			countdown_timer.start()
			tip.visible = false
			game_started = true
			time_since_start = 0.0

func _process(delta):
	time_since_start += delta
	time_since_last_cactus += delta
	
	if game_started and car_spawning_enabled:
		time_since_last_spawn += delta
		
		if time_since_start >= CAR_SPAWN_DELAY:
			if time_since_last_spawn >= car_spawn_interval:
				spawn_car()
				time_since_last_spawn = 0.0
				car_spawn_interval = randf_range(0.8, maxCarRate)
	
	if time_since_last_cactus >= cactus_spawn_interval:
		spawn_cactus()
		time_since_last_cactus = 0.0
		cactus_spawn_interval = randf_range(0.3, 0.7)
	
	scroll_background(delta)

func update_countdown():
	var display_value = (countdown_time / INITIAL_COUNTDOWN_TIME) * 100
	countdown_label.text = "%.1f" % display_value

func _on_countdown_timer_timeout():
	if countdown_finished:
		return
	
	countdown_time -= 0.1
	update_countdown()

	if countdown_time <= 1.0:
		car_spawning_enabled = false
	
	if countdown_time <= 0:
		countdown_finished = true
		
		$CountdownLabel.text = ""
		GameState.current_station = 1
		await FadeEffect.fade_out()
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func spawn_car():
	var car = CAR_SCENE.instantiate()
	var random_x = POSITIONS[randi() % POSITIONS.size()]
	car.position = Vector2(random_x, SPAWN_Y)
	add_child(car)

func spawn_cactus():
	var cactus = CACTUS.instantiate()
	var random_side = randi_range(1, 2)
	var random_x = 0
	if random_side == 1:
		random_x = randf_range(CACTUSPOSITIONS[0], CACTUSPOSITIONS[1])
	elif random_side == 2:
		random_x = randf_range(CACTUSPOSITIONS[2], CACTUSPOSITIONS[3])
	cactus.position = Vector2(random_x, SPAWN_Y)
	add_child(cactus)

func scroll_background(delta):
	back1.position.y += SCROLL_SPEED * delta
	back2.position.y += SCROLL_SPEED * delta
	
	if back1.position.y >= BACKGROUND_HEIGHT:
		back1.position.y = back2.position.y - BACKGROUND_HEIGHT
	
	if back2.position.y >= BACKGROUND_HEIGHT:
		back2.position.y = back1.position.y - BACKGROUND_HEIGHT

func _on_rv_area_entered(area):
	area.queue_free()
	Stars.fail()
	strike.visible = true
	var strike_timer = get_tree().create_timer(1)
	await strike_timer.timeout
	strike.visible = false
