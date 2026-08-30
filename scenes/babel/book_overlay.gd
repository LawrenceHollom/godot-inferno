class_name BookOverlay
extends Control

@export var shelf_root: Container
@export var highlight: TextureRect
@export var book_container: Control
@export var book_text: Label
@export var page_count: Label
@export var room_code: String = "0"
@export var case_number: int = 0

## All books in shelf order, with each shelf ordered left to right.
var books: Array[Book] = []
var shelves: Array[Array] = []

var selected_shelf_number: int = 0
var selected_book_number: int = 0
var book_pages: Array[String] = []
var current_page: int = 0

signal closed


func _ready() -> void:
	_read_books()
	book_container.hide()
	highlight.show()
	call_deferred("_update_highlight")


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.echo:
		return

	if book_container.visible:
		if event.is_action_pressed("escape"):
			_close_book()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("left"):
			_change_page(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("right"):
			_change_page(1)
			get_viewport().set_input_as_handled()
		elif _is_overlay_input(event):
			get_viewport().set_input_as_handled()
		return

	var direction := Vector2i.ZERO
	if event.is_action_pressed("up"):
		direction = Vector2i.UP
	elif event.is_action_pressed("down"):
		direction = Vector2i.DOWN
	elif event.is_action_pressed("left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed("right"):
		direction = Vector2i.RIGHT

	if direction != Vector2i.ZERO:
		_move_highlight(direction)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("enter"):
		_open_selected_book()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("escape"):
		hide()
		closed.emit()
		get_viewport().set_input_as_handled()


## Updates the room used for every book's deterministic text and image choices.
## This may be called before or after the overlay enters the scene tree.
func configure(new_room_code: String, new_case_number: int) -> void:
	room_code = new_room_code
	case_number = new_case_number
	selected_shelf_number = 0
	selected_book_number = 0
	if is_node_ready():
		_read_books()
		book_container.hide()
		highlight.show()
		call_deferred("_update_highlight")


func _read_books() -> void:
	books.clear()
	shelves.clear()
	if shelf_root == null:
		push_error("BookOverlay has no shelf root assigned.")
		return

	var shelf_number: int = 0
	for shelf_node: Node in shelf_root.get_children():
		var shelf_books: Array[Book] = []
		_find_books(shelf_node, shelf_books)
		if shelf_books.is_empty():
			continue
		if shelf_number > 3:
			push_warning("BookOverlay contains more than four populated shelves; extras are ignored.")
			break

		for book_number: int in shelf_books.size():
			var book: Book = shelf_books[book_number]
			book.configure(room_code, shelf_number, book_number, case_number)
			books.append(book)
		shelves.append(shelf_books)
		shelf_number += 1

	if not shelves.is_empty():
		selected_shelf_number = clampi(selected_shelf_number, 0, shelves.size() - 1)
		selected_book_number = clampi(
			selected_book_number,
			0,
			shelves[selected_shelf_number].size() - 1,
		)


func _find_books(parent: Node, result: Array[Book]) -> void:
	if parent is Book:
		result.append(parent)
		return
	for child: Node in parent.get_children():
		_find_books(child, result)


func _move_highlight(direction: Vector2i) -> void:
	if shelves.is_empty():
		return

	if direction.y != 0:
		selected_shelf_number = clampi(
			selected_shelf_number + direction.y,
			0,
			shelves.size() - 1,
		)
		selected_book_number = mini(
			selected_book_number,
			shelves[selected_shelf_number].size() - 1,
		)
	elif direction.x != 0:
		selected_book_number = clampi(
			selected_book_number + direction.x,
			0,
			shelves[selected_shelf_number].size() - 1,
		)

	_update_highlight()


func _update_highlight() -> void:
	var selected_book: Book = _get_selected_book()
	if selected_book == null:
		highlight.hide()
		return
	highlight.global_position = selected_book.global_position - Vector2.ONE


func _get_selected_book() -> Book:
	if shelves.is_empty():
		return null
	return shelves[selected_shelf_number][selected_book_number] as Book


func _open_selected_book() -> void:
	var selected_book: Book = _get_selected_book()
	if selected_book == null:
		return
	var full_text: String = GlobalState.get_book_text(
		selected_book.room_code,
		selected_book.shelf_number,
		selected_book.book_number,
		selected_book.case_number,
	)
	highlight.hide()
	book_container.show()
	book_pages = _paginate_text(full_text)
	current_page = 0
	_show_current_page()


func _close_book() -> void:
	book_container.hide()
	highlight.show()
	_update_highlight()


func _change_page(direction: int) -> void:
	if book_pages.is_empty():
		return
	current_page = clampi(current_page + direction, 0, book_pages.size() - 1)
	_show_current_page()


func _show_current_page() -> void:
	book_text.text = book_pages[current_page]
	page_count.text = "%d/%d" % [current_page + 1, book_pages.size()]


func _paginate_text(full_text: String) -> Array[String]:
	var pages: Array[String] = []
	var remaining: String = full_text.strip_edges()
	if remaining.is_empty():
		pages.append("")
		return pages

	while not remaining.is_empty():
		if _text_fits(remaining):
			pages.append(remaining)
			break

		var low: int = 1
		var high: int = remaining.length()
		var fitting_characters: int = 1
		while low <= high:
			var midpoint: int = (low + high) / 2
			if _text_fits(remaining.substr(0, midpoint)):
				fitting_characters = midpoint
				low = midpoint + 1
			else:
				high = midpoint - 1

		var split_position: int = _find_word_boundary(remaining, fitting_characters)
		var page: String = remaining.substr(0, split_position).strip_edges()
		if page.is_empty():
			split_position = fitting_characters
			page = remaining.substr(0, split_position)
		pages.append(page)
		remaining = remaining.substr(split_position).strip_edges()

	return pages


func _text_fits(candidate: String) -> bool:
	book_text.text = candidate
	return book_text.get_line_count() <= book_text.get_visible_line_count()


func _find_word_boundary(text: String, maximum_position: int) -> int:
	var position: int = maximum_position
	while position > 0:
		var character: String = text.substr(position - 1, 1)
		if character in [" ", "\n", "\r", "\t"]:
			return position
		position -= 1
	return maximum_position


func _is_overlay_input(event: InputEvent) -> bool:
	return (
		event.is_action_pressed("up")
		or event.is_action_pressed("down")
		or event.is_action_pressed("left")
		or event.is_action_pressed("right")
		or event.is_action_pressed("enter")
	)
