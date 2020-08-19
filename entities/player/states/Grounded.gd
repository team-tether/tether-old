extends "./Untethered.gd"

func on_enter(player):
	player.rig.current_state = 'Grounded'

func on_physics_process(player: Player, delta):
	.on_physics_process(player, delta)

	if !player.ground_ray_normal():
		go_to("Falling")
	
	#Hop
	var input_direction = player.input_direction()
	if input_direction.x != 0:
		var hop_speed = player.int_random_range(0, 1)
		var hop_height = -player.int_random_range(22, 32)
		player.acceleration += Vector2(input_direction.x * hop_speed, hop_height)
		player.velocity += player.acceleration
