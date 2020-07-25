extends KinematicBody2D
class_name Player


export var gravity = 12.5
export var starting_acceleration = Vector2.ZERO
export var starting_velocity = Vector2.ZERO
export var starting_angular_velocity: float = 0
var starting_position: Vector2

var acceleration = starting_acceleration
var velocity = starting_velocity
var angular_velocity = starting_angular_velocity

export var max_rope_length = 300
export var rope_shot_angle = PI/4
export var rope_shot_speed = 20
var rope_shot_length = 0
var is_shooting_rope = false

onready var states: FSM = $States as FSM
onready var sprite = $Sprite
onready var camera = $Camera2D

onready var left_wall_ray = $LeftWallRay
onready var right_wall_ray = $RightWallRay

onready var rope = $Rope
onready var rope_shot = $RopeShot
onready var rope_shot_ray: RayCast2D = $RopeShotRay

func _ready():
	starting_position = position
	
	remove_child(rope)
	get_parent().call_deferred("add_child", rope)
	
	shoot_rope()

func _process(_delta):
	rope.update_body_pos(position)
	
	if rope_shot.visible:
		rope_shot.set_point_position(1, rope_shot_ray.cast_to)
	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	if Input.is_action_just_pressed("respawn"):
		die()

func _physics_process(_delta):
	acceleration = Vector2.DOWN * gravity
	velocity += acceleration
	
func reset():
	states.go_to("Falling")
	acceleration = starting_acceleration
	velocity = starting_velocity
	position = starting_position
	angular_velocity = starting_angular_velocity
	rope.reset()
	rope_shot_angle = PI/4
	is_shooting_rope = false

func die():
	hide()
	reset()
	yield(get_tree().create_timer(0.25), "timeout")
	show()
	shoot_rope()
	
func wall_rays_normal():
	if left_wall_ray.is_colliding():
		return left_wall_ray.get_collision_normal()
	
	if right_wall_ray.is_colliding():
		return right_wall_ray.get_collision_normal()
	
	
func shoot_rope():
	if is_shooting_rope:
		return
	
	rope_shot_length = 0
	is_shooting_rope = true
	rope_shot.show()
	rope_shot.add_point(Vector2.ZERO)
	rope_shot.add_point(Vector2.ZERO)
	
	while is_shooting_rope and rope_shot_length <= max_rope_length and states.current_state.name == "Falling":
		var rope_v = Vector2.UP.rotated(rope_shot_angle) * rope_shot_length
		rope_shot_ray.cast_to = rope_v
		rope_shot_ray.force_raycast_update()
	
		if rope_shot_ray.is_colliding():
			var point = rope_shot_ray.get_collision_point()
			var normal = rope_shot_ray.get_collision_normal()
			var collider = rope_shot_ray.get_collider()
			
			if collider is TileMap:
				var tilemap: TileMap = collider as TileMap
				var cell = tilemap.get_cellv(tilemap.world_to_map(point - normal))
				if tilemap.tile_set.tile_get_name(cell) == "metal":
					break
			
			rope.reset()
			rope.length = position.distance_to(point)
			rope.push(point + normal + (position - point).normalized())
			rope_shot_length = 0
			states.go_to("Tethered")
			break
			
		rope_shot_length += rope_shot_speed
		yield(get_tree(), "physics_frame")
	
	rope_shot_length = 0
	rope_shot.clear_points()
	rope_shot.hide()
	is_shooting_rope = false

func get_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
