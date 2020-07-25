extends State

export var speed = 15
export var drag = 0.99
export var max_rope_shot_angle = PI/4
export var rope_length_speed = 200
export var restitution = 1
export var active_restitution = 1.3
export var max_velocity_mag = 1600

var last_delta_angle = 0

onready var rope_ray: RayCast2D = get_node("../../RopeRay")

func on_enter(player):
	player.rope.show()
		
func on_exit(player):
	var rope_flipped = (player.rope.pivot() - player.body.position).angle_to(player.body.velocity) > 0
	player.angular_velocity = player.body.velocity.length() * .04 * (-1 if rope_flipped else 1)
	player.rope.hide()
	player.sprite.rotation = 0

func on_physics_process(player: Player, delta):
	var move_direction = player.get_move_direction()
	var pivot = player.rope.pivot()
	var to_pivot = player.body.position - pivot
	var tangent = to_pivot.tangent().normalized()
	
	if move_direction.x != 0:
			player.body.acceleration += Vector2(move_direction.x * speed, speed)
	
	player.body.velocity += player.body.acceleration
	player.body.velocity = tangent * player.body.velocity.dot(tangent) * drag
	
	if move_direction.y != 0:
		var new_rope_length = player.rope.length + move_direction.y * rope_length_speed * delta
		player.body.velocity *= pow(player.rope.length / new_rope_length, 1)
		player.rope.length = new_rope_length
		
	player.body.velocity = player.body.velocity.clamped(max_velocity_mag)
	
	var new_position = player.body.position + (player.body.velocity * delta)
	var new_to_pivot = new_position - pivot
	var new_length_to_pivot = new_to_pivot.length()
	new_position = pivot + (new_to_pivot * (player.rope.length / new_length_to_pivot))

	var move_vector = new_position - player.body.position
	var move_result = player.body.move_and_collide(move_vector)
	
	if move_result:
		player.body.velocity = -player.body.velocity * (active_restitution if move_direction.x != 0 else restitution)
		player.body.velocity = player.body.velocity.clamped(max_velocity_mag)
		
	player.sprite.rotation = -to_pivot.angle_to(Vector2.DOWN)
	
	for _i in range(64):
		rope_ray.position = player.rope.pivot()
		rope_ray.cast_to = player.body.position - rope_ray.position
		rope_ray.force_raycast_update()
		
		if !rope_ray.is_colliding():
			break
		
		var iterations = 20
		var point = rope_ray.get_collision_point()
#
		for i in range(iterations):
			var pos = player.body.position - move_vector.normalized() * (move_vector.length() * (float(i) / iterations))
			rope_ray.cast_to = pos - rope_ray.position
			rope_ray.force_raycast_update()
			point = rope_ray.get_collision_point()
			point += rope_ray.get_collision_normal() + (pos - point).normalized()
			if !rope_ray.is_colliding():
				break
		
		if point != player.rope.pivot():
			player.rope.push(point)

	if player.rope.previous_pivot():
		var ss = player.get_world_2d().get_direct_space_state()
		var shape = ConvexPolygonShape2D.new()
		shape.points = PoolVector2Array([
			player.body.position,
			player.rope.pivot(),
			player.rope.previous_pivot()
		])
		var query = Physics2DShapeQueryParameters.new()
		query.set_shape(shape)
		query.set_exclude([player.body])
#		query.margin = -2
		var res = ss.intersect_shape(query)
		if !res:
			player.rope.pop()

	var resulting_to_pivot = player.body.position - player.rope.pivot()
	player.rope.length = resulting_to_pivot.length()
	player.rope_shot_angle = clamp(to_pivot.angle_to(Vector2.DOWN), -max_rope_shot_angle, max_rope_shot_angle)
	
	if Input.is_action_just_pressed("toggle_rope"):
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
