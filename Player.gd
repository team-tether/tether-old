extends KinematicBody2D

enum PlayerState {
	GROUNDED,
	FALLING,
	TETHERED
}

export var gravity = 10
export var move_speed = 10
export var ground_drag = 0.8
export var air_drag = 0.8
export var jump_force = -500
export var velocity_input_threshold = Vector2(300, 300)

var acceleration = Vector2()
var velocity = Vector2()
var state = PlayerState.FALLING

onready var sprite = $Sprite

func _ready():
	rset_config("velocity", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTE)

func _normal_movement(drag):
	var apply_drag = false
	acceleration = Vector2(0, gravity)
	
	if is_network_master():
		var move_direction = _get_move_direction()
		var move_force = move_direction * move_speed
		
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

func _physics_process(_delta):
	state = _next_state(state)

	match state:
		PlayerState.GROUNDED:
			_normal_movement(ground_drag)
			if Input.is_action_just_pressed("jump"):
				_jump()
		PlayerState.FALLING:
			_normal_movement(air_drag)

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	if is_network_master():
		rset("position", position)
		rset("velocity", velocity)


func _jump():
	velocity.y = jump_force

func _get_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		0
	)
