extends State

export var speed = 15
export var drag = 0.99
export var rope_length_speed = 200
export var restitution = 1
export var active_restitution = 1.3
export var max_velocity_mag = 1600

var last_delta_angle = 0

onready var rope_ray: RayCast2D = get_node("../../RopeRay")

func on_enter(player):
	player.rope.show()

func on_exit(player):
	var rope_flipped = (player.rope.pivot() - player.position).angle_to(player.velocity) > 0
	player.angular_velocity = player.velocity.length() * .04 * (-1 if rope_flipped else 1)
	player.rope.hide()
	player.sprite.rotation = 0

func on_physics_process(player: Player, delta):
	var input_direction = player.input_direction()
	var pivot = player.rope.pivot()
	var to_pivot = player.position - pivot
	var tangent = to_pivot.tangent().normalized()
	
	if !is_equal_approx(player.velocity.x, 0):
		player.sprite.flip_h = player.velocity.x < 0
	
	if input_direction.x != 0:
			player.acceleration += Vector2(input_direction.x * speed, speed)
	
	player.velocity += player.acceleration
	player.velocity = tangent * player.velocity.dot(tangent) * drag
	
	if input_direction.y != 0:
		var new_rope_length = player.rope.free_length + input_direction.y * rope_length_speed * delta
		var captured_length = player.rope.length - player.rope.free_length
		var new_total_length = captured_length + new_rope_length
		if new_total_length > player.max_rope_length:
			new_rope_length -= new_total_length - player.max_rope_length
		if new_total_length < player.min_rope_length:
			new_rope_length += player.min_rope_length - new_total_length
		
		player.velocity *= pow(player.rope.free_length / new_rope_length, 1)
		player.rope.free_length = new_rope_length
		
	player.velocity = player.velocity.clamped(max_velocity_mag)
	
	var new_position = player.position + (player.velocity * delta)
	var new_to_pivot = new_position - pivot
	var new_length_to_pivot = new_to_pivot.length()
	new_position = pivot + (new_to_pivot * (player.rope.free_length / new_length_to_pivot))

	var move_vector = new_position - player.position
	var move_result = player.move_and_collide(move_vector)
	
	if move_result:
		player.velocity = -player.velocity * (active_restitution if input_direction.x != 0 else restitution)
		player.velocity = player.velocity.clamped(max_velocity_mag)
		
	player.sprite.rotation = -to_pivot.angle_to(Vector2.DOWN)
	
	for _i in range(64):
		var from_pivot = player.rope.pivot() - player.position
		rope_ray.position = from_pivot
		rope_ray.cast_to = -from_pivot
		rope_ray.force_raycast_update()
		 
		if !rope_ray.is_colliding():
			break
		
		var iterations = 20
		var point = rope_ray.get_collision_point()
		
		for i in range(iterations):
			var pos = player.position - move_vector.normalized() * (move_vector.length() * (float(i) / iterations))
			var new_from_pivot = player.rope.pivot() - pos
			rope_ray.cast_to = -new_from_pivot
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
			player.position,
			player.rope.pivot(),
			player.rope.previous_pivot()
		])
		var query = Physics2DShapeQueryParameters.new()
		query.set_shape(shape)
		query.set_exclude([player])
		var res = ss.intersect_shape(query)
		if !res:
			player.rope.pop()

	var resulting_to_pivot = player.position - player.rope.pivot()
	player.rope.free_length = resulting_to_pivot.length()
	player.rope_shot_angle = to_pivot.angle_to(Vector2.DOWN)
	
	if Input.is_action_just_pressed("toggle_rope"):
		go_to("Falling")
