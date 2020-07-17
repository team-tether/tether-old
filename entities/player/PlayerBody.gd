extends KinematicBody2D

var acceleration = Vector2()
var velocity = Vector2()
var angular_velocity = 0

func _ready():
	rset_config("velocity", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTE)
#	rset_config("rotation", MultiplayerAPI.RPC_MODE_REMOTE)

func _physics_process(delta):
	if is_network_master():
		rset("velocity", velocity)
		rset("position", position)
#		rset("rotation", rotation)
