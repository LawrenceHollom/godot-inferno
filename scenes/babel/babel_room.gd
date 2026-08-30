extends Control

class_name BabelRoom

# This is an entirely visual class, with no direct gameplay functionality

@export var bookcases: Array[Bookcase]

const Y_OFF: float = 144
const X_OFF: float = 48

const MOVE_DURATION: float = 0.5

signal move_finished

func setup_for_room(room_code: String):
	for i in len(bookcases):
		bookcases[i].configure(room_code, i)


func get_visible_special_book() -> TextureRect:
	for bookcase: Bookcase in bookcases:
		var special_book: TextureRect = bookcase.get_visible_special_book()
		if special_book != null:
			return special_book
	return null

func get_offset_for_room_move(door: int) -> Vector2:
	match door:
		0:
			return Vector2(0, Y_OFF)
		1:
			return Vector2(-X_OFF, -Y_OFF)
		2:
			return Vector2(0, -Y_OFF)
		3:
			return Vector2(X_OFF, -Y_OFF)
	return Vector2(99, 99)

func slerp_in(door: int) -> void:
	position = get_offset_for_room_move(door)
	visible = true
	var tween := create_tween()
	tween.tween_property(self, "position", Vector2.ZERO, MOVE_DURATION)
	tween.tween_callback(move_finished.emit)

	
func slerp_out(door: int) -> void:
	position = Vector2.ZERO
	visible = true
	var target: Vector2 = -get_offset_for_room_move(door)
	var tween := create_tween()
	tween.tween_property(self, "position", target, MOVE_DURATION)
	tween.tween_property(self, "visible", false, 0)
	tween.tween_callback(move_finished.emit)
