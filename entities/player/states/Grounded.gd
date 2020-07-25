extends "./Untethered.gd"

func on_enter(player):
	player.sprite.rotation = 0

func on_physics_process(player, delta):
	.on_physics_process(player, delta)

	if !player.is_on_floor():
		go_to("Falling")
