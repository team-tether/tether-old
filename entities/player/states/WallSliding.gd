extends "./Untethered.gd"

func on_enter(player):
	player.current_state = 'WallSliding'

func on_physics_process(player: Player, delta):
	.on_physics_process(player, delta)
	
	var wall_normal = player.wall_rays_normal()
	
	if player.is_on_floor():
		return go_to("Grounded")
	
	if !wall_normal:
		return go_to("Falling")

	player.rope_shot_angle = sign(wall_normal.x) * abs(player.rope_shot_angle)
