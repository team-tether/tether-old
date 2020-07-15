extends Node2D

class_name Player

export var gravity = 12.5
export var move_speed = 10
export var velocity_input_threshold = Vector2(300, 300)

export var max_rope_length = 300
export var rope_shoot_angle = -PI/4
export var rope_shot_speed = 20
var rope_shot_length = 0

onready var body = $Body
onready var states: FSM = $States as FSM
onready var sprite = $Body/Sprite
onready var rope = $Rope
onready var rope_shot = $RopeShot
onready var rope_shot_ray = $RopeShotRay
onready var camera = $Body/Camera2D

func _ready():
	if is_network_master():
		camera.current = true
		yield(get_tree().create_timer(0.01), "timeout")
		shoot_rope()

func _process(delta):
	rope.update_body_pos(body.position)
	if body.velocity.x != 0:
		sprite.flip_h = body.velocity.x < 0

func set_body_position(pos):
	body.position = pos
	
func shoot_rope():
	rope_shot.show()
	rope_shot.add_point(body.position)
	rope_shot.add_point(body.position)
	
	while rope_shot_length <= max_rope_length and states.current_state.name == "Falling":
		var rope_v = Vector2.UP.rotated(rope_shoot_angle) * rope_shot_length
		rope_shot.set_point_position(0, body.position)
		rope_shot.set_point_position(1, body.position + rope_v)
		
		rope_shot_ray.position = body.position
		rope_shot_ray.cast_to = rope_v
		rope_shot_ray.force_raycast_update()
	
		if rope_shot_ray.is_colliding():
			var point = rope_shot_ray.get_collision_point()
			rope.reset()
			rope.length = body.position.distance_to(point)
			rope.push(point + rope_shot_ray.get_collision_normal() + (body.position - point).normalized())
			rope_shot_length = 0
			states.go_to("Tethered")
			break
			
		rope_shot_length += rope_shot_speed
		yield(get_tree(), "idle_frame")
	
	rope_shot_length = 0
	rope_shot.clear_points()
	rope_shot.hide()

func normal_movement(delta, drag):
	body.acceleration = Vector2.DOWN * gravity
	
	if is_network_master():
		var move_direction = get_move_direction()
		var move_force = move_direction * Vector2.RIGHT * move_speed
		
		body.acceleration += move_force
		body.velocity += body.acceleration
		
		if abs(body.velocity.x) > velocity_input_threshold.x:
			body.velocity.x -= move_force.x
	
		if abs(body.velocity.y) > velocity_input_threshold.y:
			body.velocity.y -= move_force.y
	
		if sign(move_direction.x) != sign(body.velocity.x):
			body.velocity.x *= drag
	else:
		body.velocity += body.acceleration

	body.velocity = body.move_and_slide_with_snap(body.velocity, Vector2.DOWN, Vector2.UP)

func get_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
