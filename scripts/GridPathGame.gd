extends Node2D

const GRID_SIZE = 5  # 5x5 grid
const DOT_SCENE = preload("res://scenes/Dot.tscn")
const DOT_EMPTY = preload("res://assets/DotEmpty.png")
const DOT = preload("res://assets/DotStartorEnd.png")
const DOT_FILL = preload("res://assets/DotFill.png")
@onready var grid_container = $GridContainer
var current_color = null
var start_button = null
var last_click_time = 0
const CLICK_DELAY = 0.1

var flows = {}
var button_indices = {}  # Dictionary to store button indices

func _ready():
	populate_grid()
	setup_game()

func populate_grid():
	for i in range(GRID_SIZE * GRID_SIZE):
		var button = DOT_SCENE.instantiate()
		button.texture_normal = DOT_EMPTY
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button))
		grid_container.add_child(button)
		button_indices[button] = i  # Store index

func are_buttons_adjacent(button1, button2):
	var index1 = button_indices[button1]
	var index2 = button_indices[button2]

	var x1 = index1 % GRID_SIZE
	var y1 = index1 / GRID_SIZE
	var x2 = index2 % GRID_SIZE
	var y2 = index2 / GRID_SIZE

	return abs(x1 - x2) <= 1 and abs(y1 - y2) <= 1

func _on_button_pressed(button):
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_click_time < CLICK_DELAY:
		return
	last_click_time = current_time
	
	if current_color == null:
		# Start a new flow
		for color in flows:
			if button in flows[color].points and not flows[color].completed:
				current_color = color
				start_button = button
				flows[current_color].path = [button]
				print("Started Flow")
	else:
		if button == start_button:
			# Cancel the current flow
			reset_flow(current_color)
			print("Stopped Flow")
		elif button in flows[current_color].points and button != start_button and can_complete_flow(button):
			# Complete the flow if reaching the other point in the pair
			complete_flow()
		elif can_add_to_path(button):
			# Continue the flow
			button.texture_normal = DOT_FILL
			button.modulate = current_color
			flows[current_color].path.append(button)

func can_complete_flow(button):
	# Check if the button is the other point in the pair
	return button in flows[current_color].points and button != start_button

func can_add_to_path(button):
	if button.texture_normal != DOT_EMPTY:
		return false
	
	var last_button = flows[current_color].path[-1]
	return are_buttons_adjacent(last_button, button)

func complete_flow():
	print("Flow completed!")
	flows[current_color].path.append(flows[current_color].points[0] if flows[current_color].points[1] == start_button else flows[current_color].points[1])
	flows[current_color].completed = true
	current_color = null
	start_button = null

func reset_flow(color):
	for button in flows[color].path:
		button.texture_normal = DOT_EMPTY
		button.modulate = Color.WHITE
	flows[color].path.clear()


func setup_game():
	var success = false
	while not success:
		success = try_generate_puzzle()

func try_generate_puzzle() -> bool:
	var maze = generate_maze()
	var point_pairs = generate_point_pairs()
	var colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW]  # Ensure this matches the number of pairs
	var color_index = 0

	if point_pairs.size() != colors.size():
		print("Error: Number of point pairs does not match the number of colors.")
		return false

	# Clear previous point pairs and colors
	for i in range(GRID_SIZE * GRID_SIZE):
		var button = grid_container.get_child(i)
		button.texture_normal = DOT_EMPTY
		button.modulate = Color.WHITE

	for pair in point_pairs:
		if pair.size() != 2:
			print("Error: Each pair must contain exactly two indices.")
			return false
		
		var start_pair_index = pair[0]
		var end_pair_index = pair[1]

		# Convert indices to string keys to access the maze dictionary
		var start_key = str(start_pair_index)
		var end_key = str(end_pair_index)

		# Check if the keys exist in the maze dictionary
		if not maze.has(start_key) or not maze.has(end_key):
			print("Error: One or both keys are missing in the maze dictionary.")
			return false

		var start_pos = maze[start_key]
		var end_pos = maze[end_key]

		# Calculate grid indices
		var start_grid_index = int(start_pos.x + start_pos.y * GRID_SIZE)
		var end_grid_index = int(end_pos.x + end_pos.y * GRID_SIZE)

		# Ensure valid grid indices
		if start_grid_index < 0 or start_grid_index >= GRID_SIZE * GRID_SIZE or end_grid_index < 0 or end_grid_index >= GRID_SIZE * GRID_SIZE:
			print("Error: Invalid grid index calculated.")
			return false

		# Get the current color
		var color = colors[color_index]
		set_point_pair([start_grid_index, end_grid_index], color)
		
		# Cycle through colors
		color_index = (color_index + 1) % colors.size()

	# Validate each color has exactly two points
	var color_point_count = {}
	for color in colors:
		color_point_count[color] = 0

	for pair in point_pairs:
		if maze.has(str(pair[0])) and maze.has(str(pair[1])):
			var start_index = int(maze[str(pair[0])].x + maze[str(pair[0])].y * GRID_SIZE)
			var end_index = int(maze[str(pair[1])].x + maze[str(pair[1])].y * GRID_SIZE)
			var start_child = grid_container.get_child(start_index)
			var end_child = grid_container.get_child(end_index)
			var color = start_child.modulate  # Ensure to use modulate property here for consistency
			if start_child.modulate == color:
				color_point_count[color] += 1
			if end_child.modulate == color:
				color_point_count[color] += 1

	for color in colors:
		if color_point_count[color] != 2:
			print("Error: Color ", color, " does not have exactly two points assigned.")
			return false

	return true

func generate_maze() -> Dictionary:
	var grid = []
	for i in range(GRID_SIZE):
		grid.append([])
		for j in range(GRID_SIZE):
			grid[i].append(0)
	
	var maze = {}  # Use a Dictionary to store maze positions
	var stack = []
	var current = Vector2(0, 0)
	stack.push_back(current)
	grid[current.y][current.x] = 1
	
	while stack.size() > 0:
		var neighbors = get_neighbors(current)
		var valid_neighbors = []
		
		for neighbor in neighbors:
			if is_valid(neighbor, grid):
				valid_neighbors.append(neighbor)
		
		if valid_neighbors.size() > 0:
			var chosen = valid_neighbors[randi() % valid_neighbors.size()]
			grid[chosen.y][chosen.x] = 1
			stack.push_back(chosen)
			maze[str(current.x + current.y * GRID_SIZE)] = chosen  # Store positions in the Dictionary
			current = chosen
		else:
			current = stack.pop_back()
	
	return maze

func get_neighbors(pos: Vector2) -> Array:
	var neighbors = []
	var directions = [
		Vector2(0, 1),  # Down
		Vector2(0, -1), # Up
		Vector2(1, 0),  # Right
		Vector2(-1, 0)  # Left
	]
	for dir in directions:
		var neighbor = pos + dir
		if neighbor.x >= 0 and neighbor.x < GRID_SIZE and neighbor.y >= 0 and neighbor.y < GRID_SIZE:
			neighbors.append(neighbor)
	return neighbors

func is_valid(pos: Vector2, grid: Array) -> bool:
	return grid[pos.y][pos.x] == 0

func generate_point_pairs() -> Array:
	var pairs = []
	var num_pairs = 4  # Adjust the number of pairs as needed
	
	for i in range(num_pairs):
		var start_index = randi() % (GRID_SIZE * GRID_SIZE)
		var end_index = randi() % (GRID_SIZE * GRID_SIZE)
		while end_index == start_index:
			end_index = randi() % (GRID_SIZE * GRID_SIZE)
		pairs.append([start_index, end_index])
	
	return pairs

func set_point_pair(indices: Array, color: Color):
	for index in indices:
		var point = grid_container.get_child(index)
		point.texture_normal = DOT
		point.modulate = color
	flows[color] = {"points": [grid_container.get_child(indices[0]), grid_container.get_child(indices[1])], "path": [], "completed": false}




func are_buttons_adjacent_by_index(index1, index2):
	var x1 = index1 % GRID_SIZE
	var y1 = index1 / GRID_SIZE
	var x2 = index2 % GRID_SIZE
	var y2 = index2 / GRID_SIZE
	return abs(x1 - x2) <= 1 and abs(y1 - y2) <= 1
