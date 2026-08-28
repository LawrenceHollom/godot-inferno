class_name Book
extends TextureRect

const BOOK_WIDTH: int = 15
const BOOK_HEIGHT: int = 45
const BOOK_SIZE := Vector2(BOOK_WIDTH, BOOK_HEIGHT)

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
	if book_atlas == null:
		push_warning("Book has no texture atlas assigned.")
		return

	var atlas_width: int = book_atlas.get_width()
	var atlas_height: int = book_atlas.get_height()
	if atlas_width % BOOK_WIDTH != 0 or atlas_height % BOOK_HEIGHT != 0:
		push_error(
			"Book atlas dimensions must be multiples of %dx%d; got %dx%d."
			% [BOOK_WIDTH, BOOK_HEIGHT, atlas_width, atlas_height]
		)
		return

	var columns: int = atlas_width / BOOK_WIDTH
	var rows: int = atlas_height / BOOK_HEIGHT
	var image_count: int = columns * rows
	var image_index: int = GlobalState.book_controller.get_deterministic_index(
		room_code,
		shelf_number,
		book_number,
		case_number,
		image_count,
		"image",
	)
	if image_index < 0:
		return

	var column: int = image_index % columns
	var row: int = image_index / columns
	var selected_texture := AtlasTexture.new()
	selected_texture.atlas = book_atlas
	selected_texture.region = Rect2(
		column * BOOK_WIDTH,
		row * BOOK_HEIGHT,
		BOOK_WIDTH,
		BOOK_HEIGHT,
	)
	texture = selected_texture
