extends KinematicBody2D

enum PlayerState {
	GROUNDED,
	FALLING,
	TETHERED
}

export var gravity = 10
export var move_speed = 10
export var ground_drag = 0.8
export var air_drag = 1
export var tethered_move_speed = 10
export var tethered_drag = 0.99
export var untethered_drag = 1
export var jump_force = -500
export var velocity_input_threshold = Vector2(300, 300)

export var max_rope_length = 300

var acceleration = Vector2()
var velocity = Vector2()
var state = PlayerState.TETHERED

export var rope_shoot_angle = PI/4
export var max_rope_shoot_angle = PI/4

onready var sprite = $Sprite
onready var rope = $Rope

func _ready():
	rset_config("velocity", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTE)
	
	_shoot_rope()

func _tethered_movement(delta):
	var move_direction = _get_move_direction()
	var to_pivot = position - rope.pivot()
	var tangent = to_pivot.tangent().normalized()
	
	acceleration = Vector2.DOWN * gravity
	
	if move_direction.x != 0:
		acceleration += Vector2(move_direction.x * tethered_move_speed, tethered_move_speed)
		
	if move_direction.y != 0:
		rope.length += move_direction.y * 5
		acceleration -= to_pivot.normalized() * move_direction.y * tethered_move_speed
	
	velocity += acceleration
	
	velocity = tangent * velocity.dot(tangent) * tethered_drag
	
	var new_position = position + (velocity * delta)
	var new_to_pivot = new_position - rope.pivot()
	var new_length_to_pivot = new_to_pivot.length()
	new_position = rope.pivot() + (new_to_pivot * (rope.length / new_length_to_pivot))
	
	var move_result = move_and_collide(new_position - position)
	
	if move_result:
		velocity = velocity.bounce(move_result.normal)
		
	rope.length = (position - rope.pivot()).length()
	
	rope_shoot_angle = clamp(to_pivot.angle_to(Vector2.DOWN), -max_rope_shoot_angle, max_rope_shoot_angle)
	
	if Input.is_action_just_pressed("toggle_rope"):
		rope.hide()
		state = PlayerState.FALLING
		
func _shoot_rope():
	var space_state = get_world_2d().direct_space_state
	var rope_v = Vector2.UP.rotated(rope_shoot_angle) * max_rope_length
	var result = space_state.intersect_ray(position, position + rope_v, [get_rid()])
	
	if result:
		rope.reset()
		rope.length = (position - result.position).length()
		rope.push(result.position)
	
		# TODO: Better state management for this
		state = PlayerState.TETHERED
		rope.show()

func _normal_movement(delta, drag):
	var apply_drag = false
	acceleration = Vector2.DOWN * gravity
	
	if true || is_network_master():
		var move_direction = _get_move_direction()
		var move_force = move_direction * Vector2.RIGHT * move_speed
		
		acceleration += move_force
		velocity += acceleration
		
		if abs(velocity.x) > velocity_input_threshold.x:
			velocity.x -= move_force.x
	
		if abs(velocity.y) > velocity_input_threshold.y:
			velocity.y -= move_force.y
	
		if sign(move_direction.x) != sign(velocity.x):
			velocity.x *= drag
	else:
		velocity += acceleration

	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func _next_state(from_state):
	match from_state:
		PlayerState.GROUNDED:
			if !is_on_floor():
				return PlayerState.FALLING
		PlayerState.FALLING:
			if is_on_floor():
				return PlayerState.GROUNDED
	return from_state

func _physics_process(delta):
	state = _next_state(state)

	match state:
		PlayerState.GROUNDED:
			_normal_movement(delta, ground_drag)
			if Input.is_action_just_pressed("jump"):
				_jump()
		PlayerState.FALLING:
			_normal_movement(delta, air_drag)
			if Input.is_action_just_pressed("toggle_rope"):
				_shoot_rope()
		PlayerState.TETHERED:
			_tethered_movement(delta)

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	#if is_network_master():
	#	rset("position", position)
	#	rset("velocity", velocity)


func _jump():
	velocity.y = jump_force

func _get_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
