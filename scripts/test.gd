extends Area2D

@onready var collision_shape_2d = $"../Shard1/CollisionShape2D"


func _ready():
	set_process_input(true)
	queue_redraw()
	
func _process(delta: float):
	# Request a redraw every frame to ensure `_draw()` is called
	queue_redraw()


func _draw():
	draw_rect(collision_shape_2d.shape.get_rect(), Color(1, 0, 0, 0.5))  # Red rectangle for the piece
	pass
