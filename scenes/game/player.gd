extends Control

class_name Player

@export var start_pos := Vector2i.ZERO

@export var room_layout: RoomLayout

signal interacted_with(pos: Vector2i)
signal moved_to(pos: Vector2i)

var open_cells: Array[Array] # Stores the room layout as array of bool
var grid_position: Vector2i

var is_running: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	open_cells = []
	is_running = true
	for y in range(GameState.GRID_HEIGHT):
		open_cells.push_back([])
		for x in range(GameState.GRID_WIDTH):
			var is_cell_open: bool = room_layout.is_cell_open(x, y)
			open_cells[y].push_back(is_cell_open)

	grid_position = start_pos
	position = Vector2(grid_position * GameState.CELL_SIZE)


func set_grid_position(target: Vector2i) -> void:
	grid_position = target
	position = Vector2(grid_position * GameState.CELL_SIZE)


func reset_to_room_start() -> void:
	print("Player resetting to ", start_pos)
	set_grid_position(start_pos)


func _unhandled_input(event: InputEvent) -> void:
	var direction := Vector2i.ZERO

	if not is_running:
		return

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

	if not open_cells[target.y][target.x]:
		interacted_with.emit(target)
		return

	set_grid_position(target)
	moved_to.emit(target)
