extends "./Untethered.gd"

export var angular_drag = 1

func on_enter(player):
	player.current_state = 'Falling'
	
func on_exit(player):
	player.angular_velocity = 0

func on_physics_process(player, delta):
	.on_physics_process(player, delta)
	
	if player.ground_ray_normal():
		go_to("Grounded")
		
#	if player.wall_rays_normal():
#		go_to("WallSliding")
		
	player.angular_velocity *= angular_drag
