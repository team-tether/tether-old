extends Camera2D

func _ready():
	var tm: TileMap = get_node("../../TileMap")
	var rect = tm.get_used_rect()
	
	var pos = tm.map_to_world(rect.position)
	var end = tm.map_to_world(rect.end)
	
	limit_top = pos.y
	limit_left = pos.x
	limit_bottom = end.y
	limit_right = end.x
	
