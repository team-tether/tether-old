extends State

export var drag = Vector2.ONE
export var bounciness = Vector2(0.4, 0.25)

func on_physics_process(player: Player, delta):
	var collision = player.move_and_collide(player.velocity * delta)

	if collision:
		player.position += collision.remainder.slide(collision.normal)
		
		var is_wall_collision = collision.normal.abs() == Vector2.RIGHT
		if is_wall_collision or player.velocity.y > 300:
			player.velocity = player.velocity.bounce(collision.normal) * (Vector2(bounciness.x, 1) if is_wall_collision else Vector2(1, bounciness.y))
			if is_wall_collision:
				player.rope_shot_angle = abs(player.rope_shot_angle) * sign(collision.normal.x)
		else:
			player.velocity = player.velocity.slide(collision.normal)
	
	player.velocity *= drag

	if Input.is_action_just_pressed("toggle_rope"):
		player.shoot_rope()
