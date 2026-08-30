extends Node

class_name GameState

const CELL_SIZE: int = 16
const GRID_WIDTH: int = 21
const GRID_HEIGHT: int = 14
const BABEL_LIFETIME: int = 100

const DECODER: Array[int] = [3, 3, 2, 1, 1, 1, 3, 3, 2, 1, 1, 2, 
1, 2, 2, 1, 1, 2, 3, 3, 2, 1, 3, 1, 2, 1, 3, 3, 3, 3, 3, 2, 2, 3, 
1, 2, 3, 2, 1, 3, 1, 3, 2, 1, 1, 3, 2, 1, 3, 2, 3, 3, 1, 2, 3, 2, 
3, 1, 1, 3, 3, 1, 2, 1, 3, 2, 2, 3, 2, 3, 1, 3, 2, 3, 1, 2, 2, 1, 
3, 3, 2, 2, 2, 1, 3, 2, 1, 2, 3, 2, 2, 3, 1, 1, 2, 1, 1, 1, 2, 1, 
3, 2, 2, 3, 1, 3, 2, 3, 3]

const NARRATIVE: Array[String] = ["PAST", "ASHES"]

@export var room_namer: RoomNamer
@export var book_controller: BookController

var narrative_index: int = 0
var narrative_data: Dictionary[String, NarrativeData] = {}

var current_palette: PaletteData.Palette = PaletteData.Palette.FIRE
var next_palette: PaletteData.Palette = PaletteData.Palette.FIRE

enum CurrentScene {
	INTRO,
	BABEL,
	NARRATIVE,
	CONCLUSION,
}

# Emitted when the current scene should end and fade out in whatever way
signal fade_out

var state: CurrentScene = CurrentScene.INTRO


func _ready() -> void:
	narrative_data = NarrativeData.load_all()


func get_room_name(room_code: String) -> String:
	return room_namer.get_room_name(room_code)


func get_next_room_word(room_code: String, door: int) -> String:
	print("Getting next room thing: ", room_code, " door = ", door)
	return room_namer.get_next_room_word(room_code, door)


func get_book_text(room_name: String, shelf_number: int, book_number: int, case_number: int) -> String:
	return book_controller.get_book(room_name, shelf_number, book_number, case_number)


# Called when the player successfully exists Babel.
func on_babel_win() -> void:
	print("You are big winner!")
	state = CurrentScene.CONCLUSION
	fade_out.emit()


func get_presentation_name() -> String:
	match state:
		CurrentScene.INTRO:
			return "INTRO"
		CurrentScene.BABEL:
			return ""
		CurrentScene.NARRATIVE:
			return NARRATIVE[narrative_index]
	return ""


func get_narrative_data(presentation_name: String) -> NarrativeData:
	if not narrative_data.has(presentation_name):
		push_error("Narrative data '%s' was not loaded." % presentation_name)
		return null
	return narrative_data[presentation_name]



func next_standard_scene() -> void:
	match state:
		CurrentScene.INTRO:
			state = CurrentScene.BABEL
			next_palette = PaletteData.Palette.FIRE
		CurrentScene.BABEL:
			state = CurrentScene.NARRATIVE
			next_palette = narrative_data[get_presentation_name()].palette
		CurrentScene.NARRATIVE:
			state = CurrentScene.BABEL
			next_palette = PaletteData.Palette.FIRE
	fade_out.emit()


func on_fade_out_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/toplevel/transition.tscn")


func on_transition_finished() -> void:
	current_palette = next_palette
	match state:
		CurrentScene.INTRO:
			get_tree().change_scene_to_file("res://scenes/toplevel/narrative.tscn")
		CurrentScene.BABEL:
			get_tree().change_scene_to_file("res://scenes/toplevel/babel.tscn")
		CurrentScene.NARRATIVE:
			get_tree().change_scene_to_file("res://scenes/toplevel/narrative.tscn")
		CurrentScene.CONCLUSION:
			get_tree().change_scene_to_file("res://scenes/toplevel/conclusion.tscn")
