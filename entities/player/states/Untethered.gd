extends State

export var drag = Vector2.ONE
export var bounciness = 0.3

func on_physics_process(player: Player, delta):
	player.velocity *= drag
	
	var collision = player.move_and_collide(player.velocity * delta)
	
	if collision:
		if collision.normal.abs() == Vector2.RIGHT:
			player.velocity = player.velocity.bounce(collision.normal) * Vector2(bounciness, 1)
			player.rope_shot_angle = abs(player.rope_shot_angle) * sign(collision.normal.x)
		else:
			player.velocity = player.velocity.slide(collision.normal)
	
	if Input.is_action_just_pressed("toggle_rope"):
		player.shoot_rope()
