extends Area2D

const CAR = preload("res://assets/car.png")
const CAR_2 = preload("res://assets/car2.png")
const CAR_3 = preload("res://assets/car3.png")

var vertical_speed = 650.0

var horizontal_speed = 100.0

var horizontal_direction = 0.0

const HORIZONTAL_MOVEMENT_CHANCE = 0.25

func _ready():
	var sprite = $Sprite2D 

	if sprite:
		var textures = [CAR, CAR_2, CAR_3]
		var selected_texture = textures[randi() % textures.size()]

		sprite.texture = selected_texture
	else:
		print("Error: Sprite node not found. Ensure the Sprite node is a direct child of the Area2D.")

	if randf() < HORIZONTAL_MOVEMENT_CHANCE:
		if global_position.x < 505:
			horizontal_direction = 1.0 
		elif global_position.x > 650:
			horizontal_direction = -1.0 
		else:
			horizontal_direction = 0.0 

func _physics_process(delta: float):
	global_position.y += vertical_speed * delta
	
	global_position.x += horizontal_direction * horizontal_speed * delta
	
	if global_position.y > 800:
		queue_free()
