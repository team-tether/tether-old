extends "./Platforming.gd"

export var angular_drag = 1

func on_exit(player):
	player.angular_velocity = 0

func on_physics_process(player, delta):
	.on_physics_process(player, delta)
	
	if player.body.is_on_floor():
		go_to("Running")
		
	if player.wall_rays_normal():
		go_to("WallSliding")
		
	player.angular_velocity *= angular_drag
	player.sprite.rotation += player.angular_velocity * delta

	if is_network_master() and Input.is_action_just_pressed("toggle_rope"):
		player.shoot_rope()
