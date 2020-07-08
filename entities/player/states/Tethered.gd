extends "res://addons/node_fsm_plugin/state_node.gd"

export var speed = 15
export var drag = 0.99
export var max_rope_shoot_angle = PI/4
export var restitution = 1
export var active_restitution = 1.3

func on_enter(player):
	call_deferred("deferred_enter", player)
		
func deferred_enter(player):
	player.rope.show()

func on_exit(player):
	player.rope.hide()

func on_physics_process(player, delta):
	var move_direction = player.get_move_direction()
	var to_pivot = player.position - player.rope.pivot()
	var tangent = to_pivot.tangent().normalized()
	
	player.acceleration = Vector2.DOWN * player.gravity
	
	if move_direction.x != 0:
		player.acceleration += Vector2(move_direction.x * speed, speed)
		
	if move_direction.y != 0:
		var new_rope_length = player.rope.length + move_direction.y * 5
		player.acceleration *= pow(player.rope.length / new_rope_length, 2)
		player.rope.length = new_rope_length
		 
		
	# rigidBody.velocity *= Mathf.Pow(lastDistance / joint.distance, ropeDistanceModifier);
	
	player.velocity += player.acceleration
	
	player.velocity = tangent * player.velocity.dot(tangent) * drag
	
	var new_position = player.position + (player.velocity * delta)
	var new_to_pivot = new_position - player.rope.pivot()
	var new_length_to_pivot = new_to_pivot.length()
	new_position = player.rope.pivot() + (new_to_pivot * (player.rope.length / new_length_to_pivot))
	
	var move_result = player.move_and_collide(new_position - player.position)
	
	if move_result:
		player.velocity = -player.velocity * (active_restitution if move_direction.x != 0 else restitution)
		
	player.rope.length = (player.position - player.rope.pivot()).length()
	
	player.rope_shoot_angle = clamp(to_pivot.angle_to(Vector2.DOWN), -max_rope_shoot_angle, max_rope_shoot_angle)
	
	player.rotation = -to_pivot.angle_to(Vector2.DOWN)
	
	if Input.is_action_just_pressed("toggle_rope"):
		go_to("Falling")
