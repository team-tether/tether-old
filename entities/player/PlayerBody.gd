extends KinematicBody2D

remote var acceleration = Vector2()
remote var velocity = Vector2()

func _physics_process(_delta):
	if Network.connected and is_network_master():
		rset_unreliable("velocity", velocity)
		rset_unreliable("position", position)

func reset():
	acceleration = Vector2.ZERO
	velocity = Vector2.ZERO
