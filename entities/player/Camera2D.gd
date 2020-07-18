extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var tm: TileMap = get_tree().get_root().get_node("Game/TileMap")
	var rect = tm.get_used_rect()
	
	var pos = tm.map_to_world(rect.position)
	var end = tm.map_to_world(rect.end)
	
	limit_top = pos.y
	limit_left = pos.x
	limit_bottom = end.y
	limit_right = end.x
	
