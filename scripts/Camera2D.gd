extends Camera2D

@export var sensitivity : float = 1.5
@export var inertia : float = 2
@export var min_x : float = 0
@export var max_x : float = 2575.0

var _drag_start : Vector2
var _is_dragging : bool = false
var _velocity : Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_drag_start = event.position
				_is_dragging = true
				_velocity = Vector2.ZERO
			else:
				_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging:
		var delta = event.position - _drag_start
		position.x -= delta.x * sensitivity
		_velocity.x = delta.x * sensitivity
		_drag_start = event.position

func _process(delta: float) -> void:
	if not _is_dragging:
		position.x -= _velocity.x
		_velocity.x *= (1 - inertia * delta)

	position.x = clamp(position.x, min_x, max_x)
