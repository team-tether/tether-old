extends "./Untethered.gd"

func on_enter(player):
	player.sprite.rotation = 0

func on_physics_process(player: Player, delta):
	.on_physics_process(player, delta)

	if !player.ground_ray_normal():
		go_to("Falling")
