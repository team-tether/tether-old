extends "./Platforming.gd"

export(float) var jump_force = -500

func on_enter(player):
	player.sprite.rotation = 0

func on_physics_process(player, delta):
	.on_physics_process(player, delta)
	
	player.sprite.rotation = 0
	
	if !player.body.is_on_floor():
		go_to("Falling")

	if Input.is_action_just_pressed("jump"):
		player.body.velocity.y = jump_force
