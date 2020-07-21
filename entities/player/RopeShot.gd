extends Line2D

func _ready():
	if Network.connected:
		rset_config("points", MultiplayerAPI.RPC_MODE_REMOTE)
		rset_config("visible", MultiplayerAPI.RPC_MODE_REMOTE)

func _process(_delta):
	if Network.connected and is_network_master():
		rset("visible", visible)
		rset("points", points)
