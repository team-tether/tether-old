extends TileSet
tool

func _is_tile_bound(id, neighbour_id):
	return id > 0 and neighbour_id > 0 and tile_get_tile_mode(id) == TileSet.AUTO_TILE and tile_get_tile_mode(neighbour_id) == TileSet.AUTO_TILE
