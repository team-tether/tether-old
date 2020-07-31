extends Node2D

export(Color) var color = Color.black
onready var tilemap: TileMap = $"../TileMap"

func _draw():
	var mouse_pos = get_global_mouse_position()
	var map_pos = tilemap.world_to_map(mouse_pos)
	
	var rect = Rect2(tilemap.map_to_world(map_pos), tilemap.cell_size)
	
	draw_rect(rect, Color.white, false)

func _process(_delta):
	update()
