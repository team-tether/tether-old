extends "./Untethered.gd"


func on_enter(player):
	player.sprite.rotation = 0

func on_physics_process(player, delta):
	.on_physics_process(player, delta)
	
	var wall_normal = player.wall_rays_normal()
	
	if player.is_on_floor():
		return go_to("Grounded")
	
	if !wall_normal:
		return go_to("Falling")
