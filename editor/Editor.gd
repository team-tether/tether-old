extends Node2D

onready var tilemap: TileMap = $TileMap
var tileset: TileSet
onready var grid: Node2D  = $Grid

func _ready():
	tileset = tilemap.tile_set
	
func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var map_pos = tilemap.world_to_map(mouse_pos)
	
	if Input.is_action_just_pressed("editor_toggle_grid"):
		grid.visible = !grid.visible
	
	if Input.is_action_pressed("editor_add"):
		tilemap.set_cellv(map_pos, tileset.find_tile_by_name("dirt"))
		tilemap.update_bitmask_area(map_pos)
		tilemap.update_dirty_quadrants()
		
	if Input.is_action_pressed("editor_remove"):
		tilemap.set_cellv(map_pos, -1)
		tilemap.update_bitmask_area(map_pos)
		tilemap.update_dirty_quadrants()
		
	
		
