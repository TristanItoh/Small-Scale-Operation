extends Node2D

var stars = Stars.stars
@onready var grid_container = $Tip/GridContainer
@onready var animation_player = $Camera2D/AnimationPlayer
const STAR_WHOLE = preload("res://assets/starWhole.png")
const STAR_HALF = preload("res://assets/starHalf.png")
const NEW_BACKGROUND_TEXTURE = preload("res://assets/backgroundlabScreen.png")
var delay_between_stars = 0.5 
const SMALL_IMPACT = preload("res://assets/smallImpact.wav")
const PING = preload("res://assets/ping.mp3")
const LIGHTSWITCH = preload("res://assets/lightswitch.mp3")

var delay_between_points = 0.5  
@onready var points = $Tip/Points

@onready var amount_left = $AmountLeft
@onready var radius = $Radius

func _ready():
	update_stars_dramatically()
	FadeEffect.fade_in()
	amount_left.text = str(GameState.expansionPoints) + " / 100"

func update_stars_dramatically() -> void:
	var full_stars = floor(stars)
	var has_half_star = stars - full_stars >= 0.5
	
	var start_timer = get_tree().create_timer(2)
	await start_timer.timeout

	for i in range(grid_container.get_child_count()):
		var texture_rect = grid_container.get_child(i)

		if i < full_stars:
			texture_rect.texture = STAR_WHOLE 
			play_place_sound()
		elif i == full_stars and has_half_star:
			texture_rect.texture = STAR_HALF
			play_place_sound()
		else:
			texture_rect.texture = null

		texture_rect.visible = true

		var timer = get_tree().create_timer(delay_between_stars)
		await timer.timeout

	var delay_timer = get_tree().create_timer(2)
	await delay_timer.timeout

	for i in range(grid_container.get_child_count()):
		grid_container.get_child(i).visible = false

	var points_delay_timer = get_tree().create_timer(1)
	await points_delay_timer.timeout

	points.get_node("Strike Penalty/Penalty").text = str((1 * ((5 - Stars.stars) * 4)))
	var points_to_display = 10 - (1 * ((5 - Stars.stars) * 4))
	points.get_node("Earned Points/Earned").text = str(max(points_to_display, 1))

	for i in range(points.get_child_count()):
		var point_child = points.get_child(i)
		point_child.visible = true
		play_place_sound()

		var point_timer = get_tree().create_timer(delay_between_points)
		await point_timer.timeout

	var animation_timer = get_tree().create_timer(1)
	await animation_timer.timeout
	animation_player.play("toScreen")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "toScreen":
		var texture_timer = get_tree().create_timer(1)
		await texture_timer.timeout
		$Background.texture = NEW_BACKGROUND_TEXTURE
		play_light_sound()
		
		var rad_timer = get_tree().create_timer(1)
		await rad_timer.timeout
		
		amount_left.text = str(GameState.expansionPoints) + " / 50"
		GameState.calculate_expansion_points()
		GameState.batch_completed()
		
		radius.visible = true
		radius.scale.x = GameState.scaleVar
		radius.scale.y = GameState.scaleVar
		play_ping_sound()
		
		var expand_timer = get_tree().create_timer(2)
		await expand_timer.timeout
		
		GameState.calculate_expansion_points()
		radius.scale.x = GameState.scaleVar
		radius.scale.y = GameState.scaleVar
		amount_left.text = str(GameState.expansionPoints) + " / 50"
		play_place_sound()
		
		var end_timer = get_tree().create_timer(2)
		await end_timer.timeout
		
		GameState.station1()
		GameState.updateDifficulty()
		Stars.reset_stars()
		await FadeEffect.fade_out()
		if GameState.expansionPoints < GameState.pointsNeeded:
			get_tree().change_scene_to_file("res://scenes/Transport.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/Win.tscn")

func play_place_sound():
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = SMALL_IMPACT
	add_child(audio_player)
	
	audio_player.play()
	
	audio_player.finished.connect(Callable(audio_player, "queue_free"))

func play_ping_sound():
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = PING
	add_child(audio_player)
	
	audio_player.play()
	
	audio_player.finished.connect(Callable(audio_player, "queue_free"))
	
func play_light_sound():
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = LIGHTSWITCH
	add_child(audio_player)
	
	audio_player.play()
	
	audio_player.finished.connect(Callable(audio_player, "queue_free"))
