class_name Book
extends TextureRect

const BOOK_WIDTH: int = 15
const BOOK_HEIGHT: int = 45
const BOOK_SIZE := Vector2i(BOOK_WIDTH, BOOK_HEIGHT)

@export var room_code: String = "0"
@export_range(0, 3, 1) var shelf_number: int = 0
@export var book_number: int = 0
@export var case_number: int = 0
@export var book_atlas: Texture2D


func _ready() -> void:
	custom_minimum_size = BOOK_SIZE
	_update_texture()


## Sets this book's physical location. This may be called before or after the
## scene is added to the tree.
func configure(
	new_room_code: String,
	new_shelf_number: int,
	new_book_number: int,
	new_case_number: int,
) -> void:
	room_code = new_room_code
	shelf_number = new_shelf_number
	book_number = new_book_number
	case_number = new_case_number
	if is_node_ready():
		_update_texture()


func _update_texture() -> void:
	texture = BookAtlas.get_book_texture(
		book_atlas,
		BOOK_SIZE,
		room_code,
		shelf_number,
		book_number,
		case_number,
	)
