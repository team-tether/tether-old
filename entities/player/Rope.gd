extends Line2D

var free_length
var length setget ,get_length 

func get_length():
	var result = 0
	for i in range(points.size() - 1):
		result += points[i].distance_to(points[i + 1])
	return result

func _ready():
	add_point(Vector2.ZERO)
	
func push(point):
	add_point(point, 1)

func pop():
	remove_point(1)

func pivot():
	if points.size() > 1:
		return points[1]

func is_tethered():
	return points.size() > 1

func previous_pivot():
	if points.size() > 2:
		return points[2]
		
func update_body_pos(pos):
	set_point_position(0, pos)

func reset():
	var body_pos = points[0]
	clear_points()
	add_point(body_pos)
