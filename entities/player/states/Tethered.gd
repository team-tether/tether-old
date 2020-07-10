extends "res://addons/node_fsm_plugin/state_node.gd"

export var speed = 15
export var drag = 0.99
export var max_rope_shoot_angle = PI/4
export var restitution = 1
export var active_restitution = 1.3
export var max_velocity_mag = 1000

var rope_intersect_ray

func on_enter(player):
	call_deferred("deferred_enter", player)
		
func deferred_enter(player):
	player.rope.show()

func on_exit(player):
	player.rope.hide()

func on_physics_process(player, delta):
	if !is_network_master():
		return
	
	var move_direction = player.get_move_direction()
	var to_pivot = player.position - player.rope.pivot()
	var tangent = to_pivot.tangent().normalized()
	
	player.acceleration = Vector2.DOWN * player.gravity
	
	if is_network_master():
		if move_direction.x != 0:
			player.acceleration += Vector2(move_direction.x * speed, speed)
			
		if move_direction.y != 0:
			var new_rope_length = player.rope.length + move_direction.y * 5
			player.acceleration *= pow(player.rope.length / new_rope_length, 2)
			player.rope.length = new_rope_length
	
	player.velocity += player.acceleration
	
	player.velocity = tangent * player.velocity.dot(tangent) * drag
	
	player.velocity = player.velocity.clamped(max_velocity_mag)
	
	var new_position = player.position + (player.velocity * delta)
	var new_to_pivot = new_position - player.rope.pivot()
	var new_length_to_pivot = new_to_pivot.length()
	new_position = player.rope.pivot() + (new_to_pivot * (player.rope.length / new_length_to_pivot))
	
	var move_result = player.move_and_collide(new_position - player.position)
	
	if move_result:
		player.velocity = -player.velocity * (active_restitution if move_direction.x != 0 else restitution)
	
	var resulting_to_pivot = player.position - player.rope.pivot()
	player.rope.length = resulting_to_pivot.length()
	
	player.rope_shoot_angle = clamp(to_pivot.angle_to(Vector2.DOWN), -max_rope_shoot_angle, max_rope_shoot_angle)
	
	player.rotation = -to_pivot.angle_to(Vector2.DOWN)
	
	var space_state = player.get_world_2d().direct_space_state
	var rope_ray_result = space_state.intersect_ray(player.rope.pivot() + (resulting_to_pivot * 0.1), player.position, [player])
	
	if rope_ray_result:
		var collider = rope_ray_result.collider
		var owner_id = collider.shape_find_owner(rope_ray_result.shape)
		var shape_index = collider.shape_owner_get_shape_index(owner_id, rope_ray_result.shape)
		var shape = collider.shape_owner_get_shape(owner_id, rope_ray_result.shape)
		
		var tm: TileMap = collider.get_child(0)
		var map_pos = tm.world_to_map(rope_ray_result.position - rope_ray_result.normal)
		var points = []
		for p in shape.points:
			points.push_back(tm.map_to_world(map_pos) + p)
		
		var point = closest_point(points, rope_ray_result.position)
		
		player.rope.push(point)
		player.rope.length = (player.position - player.rope.pivot()).length()
	
	if is_network_master() and Input.is_action_just_pressed("toggle_rope"):
		go_to("Falling")

func closest_point(points: PoolVector2Array, point: Vector2):
	var closest_dist = INF
	var closest
	
	print(points, point)
	
	for p in points:
		var dist = p.distance_squared_to(point)
		if dist < closest_dist:
			closest_dist = dist
			closest = p
	return closest
