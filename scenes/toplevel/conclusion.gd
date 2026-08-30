extends Control

@export var player: Player

@export var door_pos: Array[Vector2i]
@export var back_door_pos: Vector2i

@export var overlay: ColorRect
@export var fire: Fire

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	overlay.visible = false
	GlobalState.transition_type = GlobalState.TransitionType.OUTRO
	GlobalState.audio_controller.stop_music()



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
			GlobalState.current_palette = PaletteData.Palette.ASH
		1:
			GlobalState.current_palette = PaletteData.Palette.FIRE
		2:
			GlobalState.current_palette = PaletteData.Palette.GREEN
	overlay.visible = true
	overlay.color = PaletteData.get_dark(GlobalState.current_palette)
	player.is_running = false
	fire.modulate = Color(0, 0, 0, 0)
	fire.visible = true
	var tween := create_tween()
	GlobalState.audio_controller.play_transition()
	tween.tween_property(fire, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.tween_method(fire.set_intensity, 0.0, 3.0, 3.0)


	# No messing around, just straight to fade_out
	GlobalState.on_fade_out_finished()
	GlobalState.audio_controller.play_transition()
