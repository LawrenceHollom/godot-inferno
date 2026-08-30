class_name SpecialBook
extends Resource

const DATA_PATH := "res://assets/data/special_books.json"

@export_group("Position")
@export var room_code: String = ""
@export var case: int = 0
@export_range(0, 3, 1) var shelf: int = 0
@export var position: int = 0

@export_group("Contents")
@export_multiline var text: String = ""
@export var overlay_texture: Texture2D
@export var bookcase_texture: Texture2D


func get_location_key() -> String:
	return make_location_key(room_code, case, shelf, position)


static func make_location_key(
	location_room_code: String,
	location_case: int,
	location_shelf: int,
	location_position: int,
) -> String:
	return "%s|%d|%d|%d" % [
		location_room_code,
		location_case,
		location_shelf,
		location_position,
	]


## Loads the small hand-authored collection from JSON. Texture fields contain
## resource paths so special books can use independent art in both presentations.
static func load_all() -> Array[SpecialBook]:
	var result: Array[SpecialBook] = []
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open special book data at %s." % DATA_PATH)
		return result

	var parsed_data: Variant = JSON.parse_string(file.get_as_text())
	if not parsed_data is Array:
		push_error("Special book data must contain a JSON array at its root.")
		return result

	for index: int in parsed_data.size():
		var raw_data: Variant = parsed_data[index]
		if not raw_data is Dictionary:
			push_warning("Ignoring special book %d because it is not an object." % index)
			continue

		var special_book := SpecialBook.new()
		special_book.room_code = str(raw_data.get("room_code", ""))
		special_book.case = int(raw_data.get("case", -1))
		special_book.shelf = int(raw_data.get("shelf", -1))
		special_book.position = int(raw_data.get("position", -1))
		special_book.text = str(raw_data.get("text", ""))
		special_book.overlay_texture = _load_texture(
			str(raw_data.get("overlay_texture", "")),
			"overlay_texture",
			index,
		)
		special_book.bookcase_texture = _load_texture(
			str(raw_data.get("bookcase_texture", "")),
			"bookcase_texture",
			index,
		)

		if not special_book._is_valid():
			push_warning("Ignoring invalid special book %d." % index)
			continue
		result.append(special_book)

	return result


static func _load_texture(path: String, field: String, entry_index: int) -> Texture2D:
	if path.is_empty():
		push_warning("Special book %d has no %s path." % [entry_index, field])
		return null
	var loaded_resource: Resource = load(path)
	if not loaded_resource is Texture2D:
		push_warning(
			"Special book %d has an invalid %s resource at '%s'."
			% [entry_index, field, path]
		)
		return null
	return loaded_resource as Texture2D


func _is_valid() -> bool:
	for character_index: int in room_code.length():
		if room_code.substr(character_index, 1) not in ["0", "1", "2"]:
			return false
	return (
		case >= 0
		and shelf >= 0
		and shelf <= 3
		and position >= 0
		and not text.is_empty()
		and overlay_texture != null
		and bookcase_texture != null
	)
