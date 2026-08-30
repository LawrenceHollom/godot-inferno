extends Control

class_name Player

@export var start_pos := Vector2i.ZERO

@export var room_layout: RoomLayout

@export_range(0.1, 30.0, 0.1, "suffix:fps") var idle_animation_fps := 4.0

signal interacted_with(pos: Vector2i)
signal moved_to(pos: Vector2i)

var open_cells: Array[Array] # Stores the room layout as array of bool
var grid_position: Vector2i

var is_running: bool

const OFFSET := Vector2(-4, 0)
const CHARACTER_TEXTURE := preload("res://assets/game/Character.png")
const SPRITESHEET_COLUMNS := 2
const SPRITESHEET_ROWS := 4
const ROW_ANIMATIONS := [&"down", &"up", &"left", &"right"]

const DIRECTION_ANIMATIONS := {
	Vector2i.DOWN: &"down",
	Vector2i.UP: &"up",
	Vector2i.LEFT: &"left",
	Vector2i.RIGHT: &"right",
}

@onready var animated_sprite: AnimatedSprite2D = $CenterContainer/Control/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_animations()
	animated_sprite.play(DIRECTION_ANIMATIONS[Vector2i.DOWN])

	open_cells = []
	is_running = true
	for y in range(GameState.GRID_HEIGHT):
		open_cells.push_back([])
		for x in range(GameState.GRID_WIDTH):
			var is_cell_open: bool = room_layout.is_cell_open(x, y)
			open_cells[y].push_back(is_cell_open)

	set_grid_position(start_pos)


func set_grid_position(target: Vector2i) -> void:
	grid_position = target
	position = Vector2(grid_position * GameState.CELL_SIZE) + OFFSET


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
		animated_sprite.play(DIRECTION_ANIMATIONS[direction])
		move_on_grid(direction)


func setup_animations() -> void:
	var sprite_frames := SpriteFrames.new()
	var frame_size := Vector2i(
		CHARACTER_TEXTURE.get_width() / SPRITESHEET_COLUMNS,
		CHARACTER_TEXTURE.get_height() / SPRITESHEET_ROWS
	)

	for row in range(SPRITESHEET_ROWS):
		var animation_name: StringName = ROW_ANIMATIONS[row]
		sprite_frames.add_animation(animation_name)
		sprite_frames.set_animation_loop(animation_name, true)
		sprite_frames.set_animation_speed(animation_name, idle_animation_fps)

		for column in range(SPRITESHEET_COLUMNS):
			var frame := AtlasTexture.new()
			frame.atlas = CHARACTER_TEXTURE
			frame.region = Rect2(Vector2i(column, row) * frame_size, frame_size)
			sprite_frames.add_frame(animation_name, frame)

	animated_sprite.sprite_frames = sprite_frames


func move_on_grid(direction: Vector2i) -> void:
	var target := grid_position + direction

	if not open_cells[target.y][target.x]:
		interacted_with.emit(target)
		return

	set_grid_position(target)
	moved_to.emit(target)
