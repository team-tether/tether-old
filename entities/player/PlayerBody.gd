extends KinematicBody2D

export var gravity = 12.5
export var acceleration = Vector2()
export var velocity = Vector2()

func reset():
	acceleration = Vector2.ZERO
	velocity = Vector2.ZERO

func _physics_process(_delta):
	acceleration = Vector2.DOWN * gravity
	velocity += acceleration
