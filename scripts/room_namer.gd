extends Node

class_name RoomNamer

const ROOM_NAMES_PATH := "res://assets/data/room_names.json"
const MAX_CODE_LENGTH := 8

var room_words: Dictionary[String, String] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	room_words = _load_room_words()


func _load_room_words() -> Dictionary[String, String]:
	var result: Dictionary[String, String] = {}
	var file: FileAccess = FileAccess.open(ROOM_NAMES_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open room-name data at %s." % ROOM_NAMES_PATH)
		return result

	var parsed_data: Variant = JSON.parse_string(file.get_as_text())
	if not parsed_data is Dictionary:
		push_error("Room-name data must contain a JSON object at its root.")
		return result

	for code_value: Variant in parsed_data:
		var code: String = str(code_value)
		var word: String = str(parsed_data[code_value]).strip_edges()
		if not _is_valid_room_code(code):
			push_warning("Ignoring invalid room-name code '%s'." % code)
			continue
		if word.is_empty():
			push_warning("Ignoring empty word for room-name code '%s'." % code)
			continue
		result[code] = word

	return result


## Builds a room name from the word assigned to every successive code prefix.
## For example, "011" uses the entries for "0", "01", and "011".
func get_room_name(room_code: String) -> String:
	if room_code.is_empty():
		return ""
	if not _is_valid_room_code(room_code):
		push_warning("Cannot name invalid room code '%s'." % room_code)
		return ""

	var words := PackedStringArray()
	var prefix: String = ""
	for index: int in room_code.length():
		prefix += room_code.substr(index, 1)
		words.append(get_word(prefix))
	return " ".join(words)


func get_next_room_word(room_code: String, door: int) -> String:
	return get_word(room_code + str(door))


func get_word(code: String) -> String:
	if len(code) > MAX_CODE_LENGTH:
		return room_words[code.right(8)]
	else:
		return room_words[code]
	


func _is_valid_room_code(room_code: String) -> bool:
	if room_code.is_empty():
		return false
	for index: int in room_code.length():
		if room_code.substr(index, 1) not in ["0", "1", "2"]:
			return false
	return true
