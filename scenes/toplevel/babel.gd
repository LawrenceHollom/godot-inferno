extends Control

const EXIT_ROOM = "000000000"

@export var player: Player

@export var room_name_label: Label
@export var timer_label: Label

@export var door_pos: Array[Vector2i]
@export var back_door_pos: Vector2i

@export var room_id: Array[int] # The id is a sequence of 1, 2, 3

var entry_door_index: int = 0

var time_left: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalState.fade_out.connect(_on_fade_out)
	room_id = []
	time_left = GlobalState.BABEL_LIFETIME


func _on_player_moved_to(pos: Vector2i) -> void:
	time_left -= 1
	timer_label.text = str(time_left)

	if pos == door_pos[0]:
		move_room(1)
	elif pos == door_pos[1]:
		move_room(2)
	elif pos == door_pos[2]:
		move_room(3)
	elif pos == back_door_pos and len(room_id) >= 1:
		move_room(0)

	if time_left == 0:
		GlobalState.next_standard_scene()


func move_room(door_index: int) -> void:
	if door_index == 0:
		entry_door_index = room_id.pop_back()
		player.set_grid_position(door_pos[entry_door_index - 1])
	else:
		entry_door_index = 0
		room_id.push_back(door_index)
		player.reset_to_room_start()
	var room_code: String = get_room_code()
	room_name_label.text = GlobalState.get_room_name(room_code)
	if room_code == EXIT_ROOM:
		GlobalState.on_babel_win()


func get_room_code() -> String:
	var out: String = ""
	for i: int in len(room_id):
		out += str((room_id[i] + GlobalState.DECODER[i]) % 3)
	return out



func _on_player_interacted_with(pos: Vector2i) -> void:
	print("Interacts with ", pos)


func _on_fade_out() -> void:
	player.is_running = false
	GlobalState.on_fade_out_finished()
