extends TileSet
tool

func _is_tile_bound(id, neighbour_id):
	return id > 0 and neighbour_id > 0
