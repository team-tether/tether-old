extends State

export(float) var drag = 1
export(float) var jump_force = -500

func on_enter(player):
	player.body.rotation = 0

func on_physics_process(player, delta):
	player.body.rotation = 0
	player.normal_movement(delta, drag)
	
	if !player.body.is_on_floor():
		go_to("Falling")

	if is_network_master() and Input.is_action_just_pressed("jump"):
		player.body.velocity.y = jump_force
