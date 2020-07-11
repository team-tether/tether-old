extends State

export var drag = 1
export var angular_drag = 1

func on_exit(player):
	player.body.angular_velocity = 0

func on_physics_process(player, delta):
	player.normal_movement(delta, drag)
	
	if player.body.is_on_floor():
		go_to("Running")
		
	player.body.angular_velocity *= angular_drag
	player.body.rotation += player.body.angular_velocity * delta

	if is_network_master() and Input.is_action_just_pressed("toggle_rope"):
		player.shoot_rope()
