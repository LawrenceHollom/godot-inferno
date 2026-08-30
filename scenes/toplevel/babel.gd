extends Control

const EXIT_ROOM = "00" #"00000000"

@export var player: Player
@export var fire: Fire

@export var room1: BabelRoom
@export var room2: BabelRoom

@export var room_name_label: Label
@export var timer_label: Label
@export var book_overlay: BookOverlay

@export var particles: Node2D

@export var door_pos: Array[Vector2i]
@export var back_door_pos: Vector2i

@export var room_id: Array[int] # The id is a sequence of 1, 2, 3

@export var room_name_labels: Array[Label]

var entry_door_index: int = 0

var active_room: BabelRoom
var inactive_room: BabelRoom

var time_left: int
var particle_target: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalState.fade_out.connect(_on_fade_out)
	room_id = []
	time_left = GlobalState.BABEL_LIFETIME
	book_overlay.visible = false
	active_room = room1
	inactive_room = room2
	active_room.visible = true
	active_room.position = Vector2.ZERO
	inactive_room.visible = false
	fire.set_intensity(0)
	setup_room_name_labels()
	_update_particles()


func _process(_delta: float) -> void:
	_update_particles()


func _update_particles() -> void:
	var new_target: Control
	if book_overlay.is_visible_in_tree():
		new_target = book_overlay.get_visible_special_book()
	else:
		new_target = active_room.get_visible_special_book()

	var should_show := new_target != null
	particles.visible = should_show
	if not should_show:
		particle_target = null
		return

	particles.global_position = new_target.get_global_transform() * (new_target.size * 0.5)
	if new_target != particle_target:
		particle_target = new_target


func _on_player_moved_to(pos: Vector2i) -> void:
	time_left -= 1
	timer_label.text = str(time_left)
	var intensity: float = 1.0 - (time_left as float / GlobalState.BABEL_LIFETIME as float)
	fire.set_intensity(intensity) 

	if pos == door_pos[0]:
		move_room(1)
	elif pos == door_pos[1]:
		move_room(2)
	elif pos == door_pos[2]:
		move_room(3)
	elif pos == back_door_pos and len(room_id) >= 1:
		move_room(0)

	if time_left == 0:
		player.is_running = false
		var tween := create_tween()
		tween.tween_method(fire.set_intensity, 1.0, 3.0, 2.0)
		tween.tween_callback(GlobalState.next_standard_scene)


func move_room(door_index: int) -> void:
	player.is_running = false
	player.visible = false
	var code: String = get_room_code()
	var next_room: String = code + str((door_index + GlobalState.DECODER[len(code)]) % 3)
	if next_room == EXIT_ROOM:
		GlobalState.on_babel_win()
		return
	for label in room_name_labels:
		label.text = ""
	active_room.slerp_out(door_index)
	inactive_room.slerp_in(door_index)
	await active_room.move_finished

	var tmp: BabelRoom = active_room
	active_room = inactive_room
	inactive_room = tmp

	if door_index == 0:
		entry_door_index = room_id.pop_back()
		player.set_grid_position(door_pos[entry_door_index - 1])
	else:
		entry_door_index = 0
		room_id.push_back(door_index)
		player.reset_to_room_start()
	player.is_running = true
	player.visible = true
	setup_room_name_labels()


func setup_room_name_labels() -> void:
	var room_code: String = get_room_code()
	print("Entered room with code ", room_code)
	active_room.setup_for_room(room_code)
	for i in range(3):
		var next_word: String = GlobalState.get_next_room_word(room_code, (i + GlobalState.DECODER[len(room_code)]) % 3)
		room_name_labels[(i + 2) % 3].text = next_word
	room_name_label.text = GlobalState.get_room_name(room_code)


func get_room_code() -> String:
	var out: String = ""
	for i: int in len(room_id):
		out += str((room_id[i] + GlobalState.DECODER[i]) % 3)
	return out



func _on_player_interacted_with(pos: Vector2i) -> void:
	if pos.x < 7 || pos.x > 15 || pos.y < 4 || pos.y > 10:
		return
	var case_num: int = ((pos.x - 8) / 2) + 4 * ((pos.y - 5) / 3)
	book_overlay.configure(get_room_code(), case_num)
	book_overlay.visible = true
	print("Interacts with case number", case_num)


func _on_fade_out() -> void:
	player.is_running = false
	GlobalState.on_fade_out_finished()
