extends KinematicBody2D

remote var acceleration = Vector2()
remote var velocity = Vector2()

func reset():
	acceleration = Vector2.ZERO
	velocity = Vector2.ZERO
