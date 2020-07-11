extends State

export var speed = 15
export var drag = 0.99
export var max_rope_shoot_angle = PI/4
export var rope_length_speed = 200
export var restitution = 1
export var active_restitution = 1.3
export var max_velocity_mag = 1600

var last_delta_angle = 0

func on_enter(player):
	player.rope.show()
		
func on_exit(player):
	var rope_flipped = (player.rope.pivot() - player.body.position).angle_to(player.body.velocity) > 0
	player.body.angular_velocity = player.body.velocity.length() * .04 * (-1 if rope_flipped else 1)
	player.rope.hide()

func on_physics_process(player: Player, delta):
	if !is_network_master():
		return

	var move_direction = player.get_move_direction()
	var to_pivot = player.body.position - player.rope.pivot()
	var tangent = to_pivot.tangent().normalized()
	
	player.body.acceleration = Vector2.DOWN * player.gravity
	
	if is_network_master() and move_direction.x != 0:
			player.body.acceleration += Vector2(move_direction.x * speed, speed)
	
	player.body.velocity += player.body.acceleration
	player.body.velocity = tangent * player.body.velocity.dot(tangent) * drag
	player.body.velocity = player.body.velocity.clamped(max_velocity_mag)
	
	if is_network_master() and move_direction.y != 0:
		var new_rope_length = player.rope.length + move_direction.y * rope_length_speed * delta
		player.body.velocity *= pow(player.rope.length / new_rope_length, 1)
		player.rope.length = new_rope_length
	
	var new_position = player.body.position + (player.body.velocity * delta)
	var new_to_pivot = new_position - player.rope.pivot()
	var new_length_to_pivot = new_to_pivot.length()
	new_position = player.rope.pivot() + (new_to_pivot * (player.rope.length / new_length_to_pivot))
	
	var move_result = player.body.move_and_collide(new_position - player.body.position)
	
	if move_result:
		player.body.velocity = -player.body.velocity * (active_restitution if move_direction.x != 0 else restitution)
	
	var resulting_to_pivot = player.body.position - player.rope.pivot()
	player.rope.length = resulting_to_pivot.length()
	player.rope_shoot_angle = clamp(to_pivot.angle_to(Vector2.DOWN), -max_rope_shoot_angle, max_rope_shoot_angle)
	
	player.body.rotation = -to_pivot.angle_to(Vector2.DOWN)
	
	var prev_pivot = player.rope.previous_pivot()
	
	var space_state = player.body.get_world_2d().direct_space_state
	var rope_ray_result = space_state.intersect_ray(player.rope.pivot() + (resulting_to_pivot * 0.1), player.body.position, [player.body])
	
	if rope_ray_result:
		var collider = rope_ray_result.collider
		var owner_id = collider.shape_find_owner(rope_ray_result.shape)
		var shape = collider.shape_owner_get_shape(owner_id, rope_ray_result.shape)
		
		var tm: TileMap = collider.get_child(0)
		var map_pos = tm.world_to_map(rope_ray_result.position - rope_ray_result.normal)
		var points = []
		for p in shape.points:
			points.push_back(tm.map_to_world(map_pos) + p)
		
		var point = closest_point(points, rope_ray_result.position)
		
		if prev_pivot:
			var delta_angle = (prev_pivot - player.rope.pivot()).angle_to(player.rope.pivot() - point)
			
			if delta_angle == 0:
				player.rope.pop()

		player.rope.push(point)
		player.rope.length = (player.body.position - player.rope.pivot()).length()
	
	var pivot = player.rope.pivot()
	if prev_pivot:
		var delta_angle = (prev_pivot - pivot).angle_to(pivot - player.body.position)
		
		if (delta_angle >= 0 and last_delta_angle < 0) or (delta_angle <= 0 and last_delta_angle > 0):
			player.rope.pop()
			player.rope.length = (player.body.position - player.rope.pivot()).length()
			last_delta_angle = 0
		else:
			last_delta_angle = delta_angle
	
	if is_network_master() and Input.is_action_just_pressed("toggle_rope"):
		go_to("Falling")
	

func closest_point(points: PoolVector2Array, point: Vector2):
	var closest_dist = INF
	var closest
	
	for p in points:
		var dist = p.distance_squared_to(point)
		if dist < closest_dist:
			closest_dist = dist
			closest = p
	return closest
