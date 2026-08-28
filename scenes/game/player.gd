extends Control

@export var start_pos := Vector2i.ZERO

@export var room_layout: RoomLayout

var open_cells: Array[Array] # Stores the room layout as array of bool
var grid_position: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	open_cells = []
	for y in range(GameState.GRID_HEIGHT):
		open_cells.push_back([])
		for x in range(GameState.GRID_WIDTH):
			var is_cell_open: bool = room_layout.is_cell_open(x, y)
			open_cells[y].push_back(is_cell_open)

	grid_position = start_pos
	position = Vector2(grid_position * GameState.CELL_SIZE)


func _unhandled_input(event: InputEvent) -> void:
	var direction := Vector2i.ZERO

	if event.is_action_pressed("up"):
		direction = Vector2i.UP
	elif event.is_action_pressed("down"):
		direction = Vector2i.DOWN
	elif event.is_action_pressed("left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed("right"):
		direction = Vector2i.RIGHT

	if direction != Vector2i.ZERO:
		move_on_grid(direction)


func move_on_grid(direction: Vector2i) -> void:
	var target := grid_position + direction

	if target.x < 0 or target.x >= GameState.GRID_WIDTH:
		return
	if target.y < 0 or target.y >= GameState.GRID_HEIGHT:
		return
	if not open_cells[target.y][target.x]:
		return

	grid_position = target
	position = Vector2(grid_position * GameState.CELL_SIZE)
