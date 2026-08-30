class_name BookAtlas
extends RefCounted


## Returns the atlas region selected for a book's physical location.
## Atlases with the same number and ordering of images will select matching art,
## even when their individual image sizes differ.
static func get_book_texture(
	book_atlas: Texture2D,
	book_size: Vector2i,
	room_code: String,
	shelf_number: int,
	book_number: int,
	case_number: int,
	for_bookcase: bool = false,
) -> Texture2D:
	var special_book: SpecialBook = GlobalState.book_controller.get_special_book(
		room_code,
		shelf_number,
		book_number,
		case_number,
	)
	if special_book != null:
		return (
			special_book.bookcase_texture
			if for_bookcase
			else special_book.overlay_texture
		)

	if book_atlas == null:
		push_warning("Book has no texture atlas assigned.")
		return null
	if book_size.x <= 0 or book_size.y <= 0:
		push_error("Book image dimensions must be positive.")
		return null

	var atlas_width: int = book_atlas.get_width()
	var atlas_height: int = book_atlas.get_height()
	if atlas_width % book_size.x != 0 or atlas_height % book_size.y != 0:
		push_error(
			"Book atlas dimensions must be multiples of %dx%d; got %dx%d."
			% [book_size.x, book_size.y, atlas_width, atlas_height]
		)
		return null

	var columns: int = atlas_width / book_size.x
	var rows: int = atlas_height / book_size.y
	var image_index: int = GlobalState.book_controller.get_deterministic_index(
		room_code,
		shelf_number,
		book_number,
		case_number,
		columns * rows,
		"image",
	)
	if image_index < 0:
		return null

	var selected_texture := AtlasTexture.new()
	selected_texture.atlas = book_atlas
	selected_texture.region = Rect2(
		(image_index % columns) * book_size.x,
		(image_index / columns) * book_size.y,
		book_size.x,
		book_size.y,
	)
	return selected_texture
