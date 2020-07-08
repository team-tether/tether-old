extends Line2D

export var global_points = PoolVector2Array()
export var length = 100

func _ready():
	_update_points()

func _process(delta):
	_update_points()
	
func _update_points():
	clear_points()
	for p in global_points:
		add_point(to_local(p))
	add_point(position)

func push(position):
	var result = global_points.push_back(position)
	_update_points()

func pop():
	global_points.remove(global_points.size() - 1)
	_update_points()

func pivot():
	return global_points[global_points.size() - 1]

func reset():
	global_points.resize(0)
	clear_points()

func is_tethered():
	return global_points.size() > 0
