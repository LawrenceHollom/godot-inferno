extends Control

class_name Bookcase

const SHELF_COUNT: int = 4
const BOOKS_PER_SHELF: int = 7
const SMALL_BOOK_SIZE := Vector2i(2, 6)

@export var room_code: String = "0"
@export var case_number: int = 0
@export var book_atlas: Texture2D

@export var grid: GridContainer

var books: Array[TextureRect] = []


func _ready() -> void:
	grid.columns = BOOKS_PER_SHELF
	_create_books()
	_update_textures()


## Sets the location represented by this bookcase. This may be called before or
## after the scene is added to the tree.
func configure(new_room_code: String, new_case_number: int) -> void:
	room_code = new_room_code
	case_number = new_case_number
	if is_node_ready():
		_update_textures()
	_create_books()
	_update_textures()


func _create_books() -> void:
	if not books.is_empty():
		return

	for shelf_number: int in SHELF_COUNT:
		for book_number: int in BOOKS_PER_SHELF:
			var book := TextureRect.new()
			book.name = "Book%d_%d" % [shelf_number + 1, book_number + 1]
			book.custom_minimum_size = SMALL_BOOK_SIZE
			book.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			book.mouse_filter = Control.MOUSE_FILTER_IGNORE
			grid.add_child(book)
			books.append(book)


func _update_textures() -> void:
	for shelf_number: int in SHELF_COUNT:
		for book_number: int in BOOKS_PER_SHELF:
			books[shelf_number * BOOKS_PER_SHELF + book_number].texture = (
				BookAtlas.get_book_texture(
					book_atlas,
					SMALL_BOOK_SIZE,
					room_code,
					shelf_number,
					book_number,
					case_number,
				)
			)
