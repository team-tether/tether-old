extends Line2D

func _ready():
	rset_config("points", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("visible", MultiplayerAPI.RPC_MODE_REMOTE)

func _process(delta):
	if is_network_master():
		rset("visible", visible)
		rset("points", points)
