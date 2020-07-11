extends KinematicBody2D

export var gravity = 12.5
export var move_speed = 10
export var ground_drag = 0.8
export var air_drag = 1
export var velocity_input_threshold = Vector2(300, 300)

export var rope_shoot_angle = PI/4
export var max_rope_length = 300

var acceleration = Vector2()
var velocity = Vector2()
var angular_velocity = 0

onready var start_time = OS.get_ticks_msec()

onready var states: FSM = $States as FSM
onready var sprite = $Sprite
onready var rope = $Rope

func _ready():
	rset_config("velocity", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("rotation", MultiplayerAPI.RPC_MODE_REMOTE)
	
	yield(get_tree().create_timer(0.01), "timeout")
	shoot_rope()

func _physics_process(delta):
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	
	if is_network_master():
		rset("velocity", velocity)
		rset("position", position)
		rset("rotation", rotation)
	
func shoot_rope():
	var rope_v = Vector2.UP.rotated(rope_shoot_angle) * max_rope_length
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, position + rope_v, [self])

	if result:
		rope.reset()
		rope.length = position.distance_to(result.position)
		rope.push(result.position)
		states.go_to("Tethered")

func normal_movement(delta, drag):
	var apply_drag = false
	acceleration = Vector2.DOWN * gravity
	
	if false and is_network_master():
		var move_direction = get_move_direction()
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

func get_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
