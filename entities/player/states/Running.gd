extends State

export var drag = 1
export var jump_force = -500

func on_enter(player):
	player.rotation = 0
	print(player.rotation_degrees)

func on_physics_process(player, delta):
	player.rotation = 0
	player.normal_movement(delta, drag)
	
	if !player.is_on_floor():
		go_to("Falling")

	if is_network_master() and Input.is_action_just_pressed("jump"):
		player.velocity.y = jump_force
