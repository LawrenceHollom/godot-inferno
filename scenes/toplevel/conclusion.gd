extends Control

@export var player: Player

@export var door_pos: Array[Vector2i]
@export var back_door_pos: Vector2i

@export var overlay: ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	overlay.visible = false



func _on_player_moved_to(pos: Vector2i) -> void:
	if pos == door_pos[0]:
		_choose_door(0)
	elif pos == door_pos[1]:
		_choose_door(1)
	elif pos == door_pos[2]:
		_choose_door(2)
	elif pos == back_door_pos:
		GlobalState.set_help_text("There is no going back now")


func _choose_door(door: int) -> void:
	match door:
		0:
			overlay.color = PaletteData.get_medium(PaletteData.Palette.ASH)
		1:
			overlay.color = PaletteData.get_medium(PaletteData.Palette.FIRE)
		2:
			overlay.color = PaletteData.get_medium(PaletteData.Palette.GREEN)
	overlay.visible = true
