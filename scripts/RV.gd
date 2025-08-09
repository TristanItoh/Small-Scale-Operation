extends Area2D

@onready var collision_shape = $CollisionShape2D

var dragging = false
var can_drag = true
var drag_offset = Vector2()

static var current_dragging_piece: Area2D = null

var drag_bounds = Rect2(Vector2(330, 500), Vector2(490, 1))

func _ready():
	set_process_input(true)

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
			var new_position = event.position - drag_offset
			new_position.x = clamp(new_position.x, drag_bounds.position.x, drag_bounds.position.x + drag_bounds.size.x)
			new_position.y = clamp(new_position.y, drag_bounds.position.y, drag_bounds.position.y + drag_bounds.size.y)
			global_position = new_position

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
