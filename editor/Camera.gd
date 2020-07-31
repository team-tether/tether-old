extends Camera2D

export var zoom_speed: float = 0.1
export var min_zoom: float = 0.5
export var max_zoom: float = 2

var moving = false

var moving_pos
var moving_mouse_pos

func adjust_zoom(by):
	var new_zoom = clamp(zoom.x + by, min_zoom, max_zoom)
	zoom = Vector2.ONE * new_zoom

func _input(event):
	if event.is_action("editor_zoom_in"):
		adjust_zoom(-zoom_speed)
	if event.is_action("editor_zoom_out"):
		adjust_zoom(zoom_speed)

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var global_mouse_pos = get_global_mouse_position()
	
	if Input.is_action_just_pressed("editor_move_camera"):
		moving = true
		moving_pos = position
		moving_mouse_pos = mouse_pos
		
	if Input.is_action_just_released("editor_move_camera"):
		moving = false
#
	if moving:
		position = moving_pos + ((moving_mouse_pos - mouse_pos) * zoom.x)
