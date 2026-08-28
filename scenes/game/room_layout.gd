extends TileMapLayer

class_name RoomLayout

func is_cell_open(x: int, y: int) -> bool:
	return get_cell_atlas_coords(Vector2i(x, y)) == Vector2i.ZERO
