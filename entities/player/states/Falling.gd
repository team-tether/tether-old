extends "res://addons/node_fsm_plugin/state_node.gd"

export var drag = 1

func on_physics_process(player, delta):
	player.normal_movement(delta, drag)
	
	player.rotation = lerp_angle(player.rotation, player.rope_shoot_angle, 0.08)
	
	if is_network_master() and Input.is_action_just_pressed("toggle_rope"):
		player.shoot_rope()
