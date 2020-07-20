extends "./Platforming.gd"

export var jump_force = Vector2(300, 400)

func on_enter(player):
	player.sprite.rotation = 0

func on_physics_process(player, delta):
	.on_physics_process(player, delta)
	
	var wall_normal = player.wall_rays_normal()
	
	if player.body.is_on_floor():
		return go_to("Running")		
	
	if !wall_normal:
		return go_to("Falling")

	if is_network_master() and Input.is_action_just_pressed("jump"):
		player.body.velocity = (wall_normal * jump_force) + (Vector2.UP * jump_force)
