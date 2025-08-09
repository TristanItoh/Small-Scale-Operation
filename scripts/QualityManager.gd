extends Node2D

@export var bag_scene: PackedScene
@export var num_bags: int = 8
@export var min_position: Vector2
@export var max_position: Vector2
@export var min_distance: float = 100.0
@onready var tip = $Tip

@onready var success = $Success

@onready var countdown_timer = $CountdownTimer
var countdown_time = 30.0
@onready var strike = $"Strike"
@onready var results_timer = $ResultsTimer
var results_delay = 2.0
var finished = false
@onready var end = $End

var waiting_for_click = true

const NON_GARBAGE_TEXTURES = [
	"res://assets/bags/3/3Bag.png",
	"res://assets/bags/4/4Bag.png",
	"res://assets/bags/5/5Bag.png",
	"res://assets/bags/6/6Bag.png"
]

const GARBAGE_TEXTURES = [
	"res://assets/bags/3/3BagTear.png",
	"res://assets/bags/3/3BagTear2.png",
	"res://assets/bags/3/3BagColor.png",
	"res://assets/bags/3/3BagColor2.png",
	"res://assets/bags/3/3BagWrong.png",
	"res://assets/bags/3/3BagWrong2.png",
	"res://assets/bags/4/4BagTear.png",
	"res://assets/bags/4/4BagTear2.png",
	"res://assets/bags/4/4BagColor.png",
	"res://assets/bags/4/4BagColor2.png",
	"res://assets/bags/4/4BagWrong.png",
	"res://assets/bags/4/4BagWrong2.png",
	"res://assets/bags/5/5BagTear.png",
	"res://assets/bags/5/5BagTear2.png",
	"res://assets/bags/5/5BagColor.png",
	"res://assets/bags/5/5BagColor2.png",
	"res://assets/bags/5/5BagWrong.png",
	"res://assets/bags/5/5BagWrong2.png",
	"res://assets/bags/6/6BagTear.png",
	"res://assets/bags/6/6BagTear2.png",
	"res://assets/bags/6/6BagColor.png",
	"res://assets/bags/6/6BagColor2.png",
	"res://assets/bags/6/6BagWrong.png",
	"res://assets/bags/6/6BagWrong2.png"
]

func _ready():
	var possible_images = []
	FadeEffect.fade_in()
	
	for i in range(6):
		possible_images.append(load(NON_GARBAGE_TEXTURES[randi() % NON_GARBAGE_TEXTURES.size()]))
	
	for i in range(4):
		possible_images.append(load(GARBAGE_TEXTURES[randi() % GARBAGE_TEXTURES.size()]))

	possible_images.shuffle()
	var selected_images = possible_images.slice(0, num_bags)
	
	while is_all_garbage(selected_images):
		possible_images.shuffle()
		selected_images = possible_images.slice(0, num_bags)

	var placed_positions = []

	for i in range(num_bags):
		var bag_instance = bag_scene.instantiate()
		var sprite = bag_instance.get_node("Sprite2D")
		
		sprite.texture = selected_images[i]
		
		var random_position = generate_valid_position(placed_positions)
		bag_instance.position = random_position
		
		placed_positions.append(random_position)
		
		add_child(bag_instance)
		
		bag_instance.add_to_group("bags")
		
	$Trash.connect("wrong_bag_placed", Callable(self, "_on_wrong_bag_placed"))
	
	countdown_timer.wait_time = 0.1
	countdown_timer.one_shot = false
	
	results_timer.timeout.connect(_on_results_timer_timeout)
	results_timer.one_shot = true
	
	if GameState.difficulty == 2:
		countdown_time = 25
	elif GameState.difficulty == 3:
		countdown_time = 22
	elif GameState.difficulty == 4:
		countdown_time = 19
	elif GameState.difficulty == 5:
		countdown_time = 16
		
	$CountdownLabel.text = "%.1f" % countdown_time

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and waiting_for_click:
			waiting_for_click = false
			countdown_timer.start()
			tip.visible = false

func generate_valid_position(placed_positions: Array) -> Vector2:
	while true:
		var random_position = Vector2(
			randf_range(min_position.x, max_position.x),
			randf_range(min_position.y, max_position.y)
		)
		
		var is_valid = true
		for pos in placed_positions:
			if random_position.distance_to(pos) < min_distance:
				is_valid = false
				break
		
		if is_valid:
			return random_position
	
	return Vector2()

func _on_countdown_timer_timeout():
	if not finished:
		countdown_time -= 0.1
		
		if countdown_time <= 0:
			countdown_time = 0
			update_timer_display()
			_handle_timer_end()
		else:
			update_timer_display()

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
	$CountdownLabel.text = ""
	Stars.fail()

	if strike != null:
		strike.visible = true
	else:
		print("Strike node not found!")

	results_timer.start(results_delay)

func _handle_timer_end():
	if check_for_win() and end.disabled == false:
		start_win_sequence()
	else:
		start_lose_sequence()

func _on_wrong_bag_placed():
	start_lose_sequence()

func update_timer_display():
	$CountdownLabel.text = "%.1f" % countdown_time

func _on_results_timer_timeout():
	await FadeEffect.fade_out()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func check_for_win() -> bool:
	for bag in get_tree().get_nodes_in_group("bags"):
		if is_garbage(bag):
			return false
	return true

func is_garbage(bag: Node) -> bool:
	var sprite = bag.get_node("Sprite2D")
	if sprite:
		var texture = sprite.texture
		if texture:
			var texture_path = texture.resource_path
			var texture_filename = texture_path.get_file()
			return extract_type_from_filename(texture_filename)
	return true

func extract_type_from_filename(filename: String) -> bool:
	if filename.contains("Tear") or filename.contains("Color") or filename.contains("Wrong"):
		return true
	return false

func is_all_garbage(images: Array) -> bool:
	for image in images:
		var path = image.resource_path
		if path in NON_GARBAGE_TEXTURES:
			return false 
	return true


func _on_end_pressed():
	end.disabled = true
	if check_for_win():
		start_win_sequence()
	else:
		start_lose_sequence()
