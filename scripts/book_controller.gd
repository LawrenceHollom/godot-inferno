extends Node

class_name BookController

const BOOKS_PATH := "res://assets/data/books.json"
const FNV_OFFSET_BASIS: int = 2166136261
const FNV_PRIME: int = 16777619
const UINT32_MASK: int = 0xffffffff

var books: Array[String] = []
var total_books: int = 0


func _ready() -> void:
	books = _load_books()
	total_books = books.size()


func _load_books() -> Array[String]:
	var result: Array[String] = []
	var file: FileAccess = FileAccess.open(BOOKS_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open book data at %s." % BOOKS_PATH)
		return result

	var parsed_data: Variant = JSON.parse_string(file.get_as_text())
	if not parsed_data is Array:
		push_error("Book data must contain a JSON array at its root.")
		return result

	for entry: Variant in parsed_data:
		if not entry is String:
			push_warning("Ignoring a book entry that is not a string.")
			continue
		var book_text: String = entry
		if book_text.is_empty():
			push_warning("Ignoring an empty book entry.")
			continue
		result.append(book_text)

	return result


## Returns a stable pseudorandom index for a physical book in a room.
## The same case, room, shelf, and position will produce the same index every run.
func get_book_index(
	room_code: String,
	shelf_number: int,
	book_number: int,
	case_number: int,
) -> int:
	if total_books == 0:
		push_error("Cannot select a book because no book data was loaded.")
		return -1
	return get_deterministic_index(
		room_code,
		shelf_number,
		book_number,
		case_number,
		total_books,
	)


## Maps a book location onto a stable index in a collection of [param option_count]
## items. [param salt] allows independent selections for text, artwork, and other
## properties without changing the physical book coordinates.
func get_deterministic_index(
	room_code: String,
	shelf_number: int,
	book_number: int,
	case_number: int,
	option_count: int,
	salt: String = "",
) -> int:
	if not _is_valid_room_code(room_code):
		push_warning("Cannot select a book for invalid room code '%s'." % room_code)
		return -1
	if shelf_number < 0 or shelf_number > 3:
		push_warning("Shelf number must be between 0 and 3, inclusive.")
		return -1
	if book_number < 0:
		push_warning("Book number cannot be negative.")
		return -1
	if case_number < 0:
		push_warning("Case number cannot be negative.")
		return -1
	if option_count <= 0:
		push_warning("A deterministic selection requires at least one option.")
		return -1

	var location_key := "%s|%d|%d|%d" % [
		room_code,
		shelf_number,
		book_number,
		case_number,
	]
	if not salt.is_empty():
		location_key += "|" + salt
	return _stable_hash(location_key) % option_count


func get_book(
	room_code: String,
	shelf_number: int,
	book_number: int,
	case_number: int,
) -> String:
	var index: int = get_book_index(room_code, shelf_number, book_number, case_number)
	return books[index] if index >= 0 else ""


func _stable_hash(value: String) -> int:
	var hash_value: int = FNV_OFFSET_BASIS
	for index: int in value.length():
		hash_value = ((hash_value ^ value.unicode_at(index)) * FNV_PRIME) & UINT32_MASK
	return hash_value


func _is_valid_room_code(room_code: String) -> bool:
	if room_code.is_empty():
		return false
	for index: int in room_code.length():
		if room_code.substr(index, 1) not in ["0", "1", "2"]:
			return false
	return true
