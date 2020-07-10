extends Line2D

export var global_points = PoolVector2Array()
export var length = 100

func _ready():
	rset_config("points", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("visible", MultiplayerAPI.RPC_MODE_REMOTE)
	_update_points()

func _process(delta):
	_update_points()
	if is_network_master():
		rset("visible", visible)
	
func _update_points():
	clear_points()
	for p in global_points:
		add_point(to_local(p))
	add_point(position)

func push(position):
	var result = global_points.push_back(position)
	_update_points()
	if is_network_master():
		rset("points", points)

func pop():
	global_points.remove(global_points.size() - 1)
	_update_points()
	if is_network_master():
		rset("points", points)

func reset():
	global_points.resize(0)
	clear_points()
	if is_network_master():
		rset("points", points)

func pivot():
	return global_points[global_points.size() - 1]

func is_tethered():
	return global_points.size() > 0
	

