extends TextureRect

var speed = 1000.0

func _physics_process(delta: float):
	global_position.y += speed * delta

	if global_position.y > 800:
		queue_free()
