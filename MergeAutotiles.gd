extends TileSet
tool

func _is_tile_bound(id, neighbour_id):
	return tile_get_tile_mode(id) == TileSet.AUTO_TILE and tile_get_tile_mode(neighbour_id) == TileSet.AUTO_TILE
