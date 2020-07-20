extends Node2D

class_name Player

export var gravity = 12.5
export var move_speed = 10
export var velocity_input_threshold = Vector2(300, 300)
var angular_velocity = 0

export var max_rope_length = 300
export var rope_shoot_angle = -PI/4
export var rope_shot_speed = 20
var rope_shot_length = 0
var is_shooting_rope = false

onready var body = $Body
onready var states: FSM = $States as FSM
onready var sprite = $Body/Sprite
onready var camera = $Body/Camera2D

onready var left_wall_ray = $Body/LeftWallRay
onready var right_wall_ray = $Body/RightWallRay

onready var rope = $Rope
onready var rope_shot = $RopeShot
onready var rope_shot_ray: RayCast2D = $RopeShotRay

func _ready():
	if is_network_master():
		camera.current = true
		yield(get_tree().create_timer(0.01), "timeout")
		shoot_rope()

func _process(delta):
	rope.update_body_pos(body.position)
	if body.velocity.x != 0:
		sprite.flip_h = body.velocity.x < 0
	if Input.is_action_just_pressed("Respawn"):
		die()
		
func die():
	hide()
	yield(get_tree().create_timer(0.5), "timeout")
	spawn()
	
func spawn():
	states.go_to("Falling")
	var spawn = get_tree().root.get_node("Game/Spawn")
	body.reset()
	rope.reset()
	body.position = spawn.position
	rope_shoot_angle = -PI/4
	show()
	shoot_rope()
	
func set_body_position(pos):
	body.position = pos
	
func wall_rays_normal():
	if left_wall_ray.is_colliding():
		return left_wall_ray.get_collision_normal()
	
	if right_wall_ray.is_colliding():
		return right_wall_ray.get_collision_normal()
	
	
func shoot_rope():
	if is_shooting_rope:
		return
	
	is_shooting_rope = true
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
			var normal = rope_shot_ray.get_collision_normal()
			var collider = rope_shot_ray.get_collider()
			
			if collider is TileMap:
				var tilemap: TileMap = collider as TileMap
				var cell = tilemap.get_cellv(tilemap.world_to_map(point - normal))
				if tilemap.tile_set.tile_get_name(cell) == "metal":
					break
			
			rope.reset()
			rope.length = body.position.distance_to(point)
			rope.push(point + normal + (body.position - point).normalized())
			rope_shot_length = 0
			states.go_to("Tethered")
			break
			
		rope_shot_length += rope_shot_speed
		yield(get_tree(), "idle_frame")
	
	rope_shot_length = 0
	rope_shot.clear_points()
	rope_shot.hide()
	is_shooting_rope = false
	
func _physics_process(_delta):
	body.acceleration = Vector2.DOWN * gravity

func get_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
