extends Area2D

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

var dragging = false
var can_drag = true
var drag_offset = Vector2()

const TEXTURE_PATHS = [
	"res://assets/3piece1.png",
	"res://assets/3piece2.png",
	"res://assets/3piece3.png",
	"res://assets/4piece1.png",
	"res://assets/4piece2.png",
	"res://assets/4piece3.png",
	"res://assets/5piece1.png",
	"res://assets/5piece2.png",
	"res://assets/5piece3.png",
	"res://assets/6piece1.png",
	"res://assets/6piece2.png",
	"res://assets/6piece3.png"
]

static var current_dragging_piece: Area2D = null

func _ready():
	set_process_input(true)
	set_random_texture()
	set_random_rotation()
	
	var base_r = 0.0 
	var base_g = 0.7 
	var base_b = 0.8 
	
	var r_variation = randf_range(-0.2, 0.2)
	var g_variation = randf_range(-0.2, 0.2)
	var b_variation = randf_range(-0.2, 0.2)
	
	var new_r = clamp(base_r + r_variation, 0.0, 1.0)
	var new_g = clamp(base_g + g_variation, 0.0, 1.0)
	var new_b = clamp(base_b + b_variation, 0.0, 1.0)
	
	var new_color = Color(new_r, new_g, new_b)
	sprite.modulate = new_color

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 :
			if event.pressed and can_drag == true:
				if is_mouse_over(event.position):
					start_drag(event.position)
			else:
				end_drag()
	elif event is InputEventMouseMotion and dragging:
		if current_dragging_piece == self:
			global_position = event.position - drag_offset
			
			var window_size = get_viewport_rect().size
			global_position.x = clamp(global_position.x, 0, window_size.x)
			global_position.y = clamp(global_position.y, 0, window_size.y)

func start_drag(mouse_position: Vector2):
	if current_dragging_piece == null:
		dragging = true
		drag_offset = mouse_position - global_position
		get_parent().move_child(self, get_parent().get_child_count() - 1)
		current_dragging_piece = self

func end_drag():
	if current_dragging_piece == self:
		dragging = false
		current_dragging_piece = null

func is_mouse_over(mouse_position: Vector2) -> bool:
	var rect = collision_shape.shape.get_rect()
	var local_mouse_position = to_local(mouse_position)
	return rect.has_point(local_mouse_position)

func set_random_texture():
	var random_index = randi() % TEXTURE_PATHS.size()
	var texture_path = TEXTURE_PATHS[random_index]
	
	var texture = load(texture_path)
	sprite.texture = texture

func set_random_rotation():
	rotation = randf_range(0, 2 * PI)

func set_can_drag(enabled: bool):
	can_drag = enabled
	dragging = enabled
