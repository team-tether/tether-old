extends KinematicBody2D
class_name Player

export var gravity = 10.5
export var starting_acceleration = Vector2.ZERO
export var starting_velocity = Vector2.ZERO
export var starting_angular_velocity: float = 0
var starting_position: Vector2

var acceleration = starting_acceleration
var velocity: Vector2 = starting_velocity
var prev_velocity = velocity
var angular_velocity = starting_angular_velocity

export var min_rope_length = 15
export var max_rope_length = 450
export var max_rope_shot_angle = PI/4
export var rope_shot_angle = PI/4 setget set_rope_shot_angle
export var rope_shot_speed = 20
var rope_length = 0.0
var rope_shot_length = 0.0
var is_shooting_rope = false

onready var states: FSM = $States as FSM

onready var rig: Rig = $Rig
onready var collider: CollisionShape2D = $Collider

onready var left_wall_ray = $LeftWallRay
onready var right_wall_ray = $RightWallRay
onready var ground_ray = $GroundRay

onready var rope = $Rope
onready var rope_shot = $RopeShot
onready var rope_shot_ray: RayCast2D = $RopeShotRay

onready var rope_direction_indicator = $RopeDirectionIndicator

# TODO: Better way to reference these
var rig_textures = ["res://entities/player/DefaultTextures.tres"]

func set_rope_shot_angle(angle):
	rope_shot_angle = clamp(angle, -max_rope_shot_angle, max_rope_shot_angle)

func _ready():
	starting_position = position
	
	remove_child(rope)
	get_parent().call_deferred("add_child", rope)
	
	yield(get_tree().create_timer(0.1), "timeout")
	shoot_rope()

func _process(_delta):
	rope.update_body_pos(position)
	
	if rope_shot.visible:
		rope_shot.set_point_position(1, rope_shot_ray.cast_to)

func _physics_process(_delta):
	prev_velocity = velocity
	acceleration = Vector2.DOWN * gravity
	velocity += acceleration
	
func wall_rays_normal():
	if left_wall_ray.is_colliding():
		return left_wall_ray.get_collision_normal()
	
	if right_wall_ray.is_colliding():
		return right_wall_ray.get_collision_normal()
		
func ground_ray_normal():
	if ground_ray.is_colliding():
		return ground_ray.get_collision_normal()
		
func collider_height():
	var circle = collider.shape as CircleShape2D
	return circle.radius * 2
	

func int_random_range(smin, smax):
	var total_range = smax - smin
	var rng = randi() % total_range + 1 #Creates random int
	return smin + rng

func shoot_rope():
	if ground_ray_normal(): #If player is on the ground
		if (abs(velocity.x) < 10): #...and barely moving
			var rope_shot_current_angle = rope_shot_angle
			rope_shot_angle = deg2rad(int_random_range(-40,40)) #Shoot rope in random direction
	
	rig.current_state = 'Shooting Rope'
	if is_shooting_rope:
		return
	
	rope_shot_length = 0
	is_shooting_rope = true
	rope_shot.show()
	rope_shot.add_point(Vector2.ZERO)
	rope_shot.add_point(Vector2.ZERO)
	
	while is_shooting_rope and rope_shot_length <= max_rope_length and states.current_state.name != "Tethered":
		var rope_v = Vector2.UP.rotated(rope_shot_angle) * rope_shot_length
		rope_shot_ray.cast_to = rope_v
		rope_shot_ray.force_raycast_update()
	
		if rope_shot_ray.is_colliding():
			var point = rope_shot_ray.get_collision_point()
			var normal = rope_shot_ray.get_collision_normal()
			var collider = rope_shot_ray.get_collider()
			if collider.is_in_group("unhookable"):
				break	

			rope.reset()
			rope.push(point + normal + (position - point).normalized())
			rope.free_length = position.distance_to(point)
			rope_shot_length = 0
			states.go_to("Tethered")
			break
			
		rope_shot_length += rope_shot_speed
		yield(get_tree(), "physics_frame")
	
	rope_shot_length = 0
	rope_shot.clear_points()
	rope_shot.hide()
	is_shooting_rope = false

func input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
