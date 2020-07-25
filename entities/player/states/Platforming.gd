extends State

export(float) var drag = 0.95
export(float) var move_speed = 10
export var velocity_input_threshold = Vector2(500, 500)

func on_physics_process(player, _delta):
	var move_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	var move_force = Vector2.RIGHT * move_direction * move_speed
	
	player.body.acceleration += move_force
	player.body.velocity += player.body.acceleration
	
	if abs(player.body.velocity.x) > velocity_input_threshold.x:
		player.body.velocity.x -= move_force.x

	if abs(player.body.velocity.y) > velocity_input_threshold.y:
		player.body.velocity.y -= move_force.y

	if sign(move_direction) != sign(player.body.velocity.x):
		player.body.velocity.x *= drag

	player.body.velocity = player.body.move_and_slide_with_snap(player.body.velocity, Vector2.DOWN, Vector2.UP)
