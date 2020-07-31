extends Node2D

export(Color) var color = Color.black
onready var tilemap: TileMap = $"../TileMap"

func _draw():
	var size = 1000
	var hsize = size / 2
	for x in range(-size, size):
		draw_line(tilemap.map_to_world(Vector2(-hsize, x)), tilemap.map_to_world(Vector2(hsize, x)), color)
		draw_line(tilemap.map_to_world(Vector2(x, -hsize)), tilemap.map_to_world(Vector2(x, hsize)), color)
