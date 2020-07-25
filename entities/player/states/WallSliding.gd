extends "./Untethered.gd"

func on_enter(player):
	player.is_shooting_rope = false
	player.sprite.rotation = 0
	update_rope_shot_angle(player)
	player.rope_direction_indicator.show()
	
func on_exit(player):
	player.rope_direction_indicator.hide()

func on_physics_process(player, delta):
	.on_physics_process(player, delta)
	
	var wall_normal = player.wall_rays_normal()
	
	if player.is_on_floor():
		return go_to("Grounded")
	
	if !wall_normal:
		return go_to("Falling")
		
	if !player.is_shooting_rope:
		update_rope_shot_angle(player)

func update_rope_shot_angle(player: Player):	
	var input_direction = player.input_direction()
	player.rope_shot_angle = -input_direction.angle_to(Vector2.UP)
	player.rope_direction_indicator.rotation = player.rope_shot_angle
	if input_direction.x != 0:
		player.sprite.flip_h = input_direction.x < 0
