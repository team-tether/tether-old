extends Node2D

onready var terrain: Sprite = $Terrain

var last_mouse_pos: Vector2

func _process(delta):
	var mouse_pos = get_local_mouse_position() + (terrain.texture.get_size() / 2)
		
	if !last_mouse_pos || Input.is_action_just_pressed("editor_add"):
		last_mouse_pos = mouse_pos
	
	if Input.is_action_pressed("editor_add"):
		set_terrain_color(last_mouse_pos, mouse_pos, Color.white)
		
	if Input.is_action_pressed("editor_remove"):
		set_terrain_color(last_mouse_pos, mouse_pos, Color.black)
		
	last_mouse_pos = mouse_pos
		
func set_terrain_color(prev_pos: Vector2, pos: Vector2, color: Color):
	var texture: ImageTexture = terrain.texture
	var image: Image = texture.get_data()

	image.lock()
	
	var rect: Rect2
	for p in pixels_between_points(prev_pos, pos):
		var r = set_pixels_rect(image, Rect2(p, Vector2(50, 50)), color)
		rect = r if p == prev_pos else rect.merge(r)
	
	image.unlock()

	VisualServer.texture_set_data_partial(texture.get_rid(), image, rect.position.x, rect.position.y, rect.size.x, rect.size.y, rect.position.x, rect.position.y, 0, 0)

func set_pixels_square(image: Image, pos: Vector2, size: int, color: Color) -> Rect2:
	return set_pixels_rect(image, Rect2(pos, Vector2(size, size)), color)
	
func set_pixels_rect(image: Image, rect: Rect2, color: Color):
	rect.position -= (rect.size / 2)
	rect.position
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			image.set_pixelv(rect.position + Vector2(x, y), color)
	return rect

func pixels_between_points(a: Vector2, b: Vector2) -> PoolVector2Array:
	var pixels = PoolVector2Array()
	
	if a.is_equal_approx(b):
		pixels.push_back(a)
		return pixels
	
	var delta_x = b.x - a.x
	var delta_row = abs(delta_x)
	var row_inc = sign(delta_x)
	
	var delta_y = b.y - a.y
	var delta_col = abs(delta_y)
	var col_inc = sign(delta_y)
	
	var row_accum = 0
	var col_accum = 0
	var row_cursor = a.x
	var col_cursor = a.y
	
	var counter = max(delta_col, delta_row)
	var end_pnt = counter
	if counter == delta_col:
		row_accum = end_pnt / 2
		for _i in range(counter):
			row_accum += delta_row
			if row_accum > end_pnt:
				row_accum -= end_pnt
				row_cursor += row_inc
			col_cursor += col_inc
			pixels.push_back(Vector2(row_cursor, col_cursor))
	else:
		col_accum = end_pnt / 2
		for _i in range(counter):
			col_accum += delta_col
			if col_accum > end_pnt:
				col_accum -= end_pnt
				col_cursor += col_inc
			row_cursor += row_inc
			pixels.push_back(Vector2(row_cursor, col_cursor))
	
	return pixels
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
