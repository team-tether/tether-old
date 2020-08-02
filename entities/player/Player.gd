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

#Player sprites
onready var spr_player_body: Sprite = $spr_player_body
onready var spr_player_face: Sprite = $spr_player_body/spr_player_face
onready var spr_player_hair_left: Sprite = $spr_player_body/spr_player_hair_left
onready var spr_player_hair_right: Sprite = $spr_player_body/spr_player_hair_right
onready var spr_player_hand_left: Sprite = $spr_player_body/spr_player_hand_left
onready var spr_player_hand_right: Sprite = $spr_player_body/spr_player_hand_right
#Store default positions
onready var hand_position_left_default = spr_player_hand_left.position
onready var hand_position_right_default = spr_player_hand_right.position
#Storing values the sprite system needs access to
var current_state = ''
var current_delta = 0
#Stores sprite direction so that it can be flipped vertically or horizontally
const DIRECTION_RIGHT = 1
const DIRECTION_LEFT = -1
var spr_direction = Vector2(DIRECTION_RIGHT, 1) #Set default direction
#End of sprites code

onready var left_wall_ray = $LeftWallRay
onready var right_wall_ray = $RightWallRay
onready var ground_ray = $GroundRay

onready var rope = $Rope
onready var rope_shot = $RopeShot
onready var rope_shot_ray: RayCast2D = $RopeShotRay

onready var rope_direction_indicator = $RopeDirectionIndicator

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
	animation_hander() #Run everyframe
	
	if rope_shot.visible:
		rope_shot.set_point_position(1, rope_shot_ray.cast_to)

func _physics_process(_delta):
	prev_velocity = velocity
	acceleration = Vector2.DOWN * gravity
	velocity += acceleration
	current_delta = _delta
	
func wall_rays_normal():
	if left_wall_ray.is_colliding():
		return left_wall_ray.get_collision_normal()
	
	if right_wall_ray.is_colliding():
		return right_wall_ray.get_collision_normal()
		
func ground_ray_normal():
	if ground_ray.is_colliding():
		return ground_ray.get_collision_normal()

func shoot_rope():
	current_state = 'Shooting Rope'
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
			
			if collider is TileMap:
				var tilemap: TileMap = collider as TileMap
				var cell = tilemap.get_cellv(tilemap.world_to_map(point - normal))
				if tilemap.tile_set.tile_get_name(cell) == "metal":
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


#Player animation handler
func animation_hander():
	
	#Lots of redundant code. I am just testing things.
	
	#Hide hair for now
	spr_player_hair_left.visible = false
	spr_player_hair_right.visible = false
	
	#Moved all animation code from the States
	if current_state == 'Falling': #Need a faster way to indetify current state than strings
		spr_player_body.rotation += angular_velocity * current_delta
		#Reposition hands
		spr_player_hand_left.position = Vector2(-100,-100)
		spr_player_hand_right.position = Vector2(100,-100)
	
	if current_state == 'Grounded':
		spr_player_body.rotation = 0
		#Reposition hands
		spr_player_hand_left.position = Vector2(-100,75)
		spr_player_hand_right.position = Vector2(100,75)
		
	if current_state == 'Tethered':
		#Rotate / flip body based on rope angle
		var to_pivot = position - rope.pivot() #duplicate code - bad practice
		if (velocity.x > 0):
			spr_player_body.rotation = -to_pivot.angle_to(Vector2.LEFT) #Swing right
			if spr_direction.x == DIRECTION_LEFT:
				spr_player_body.apply_scale(Vector2(DIRECTION_RIGHT * spr_direction.x, 1)) # flip
				spr_direction = Vector2(DIRECTION_RIGHT, spr_direction.y) # update direction
		else:
			spr_player_body.rotation = -to_pivot.angle_to(Vector2.RIGHT) #Swing left
			if spr_direction.x == DIRECTION_RIGHT:
				spr_player_body.apply_scale(Vector2(DIRECTION_LEFT * spr_direction.x, 1)) # flip
				spr_direction = Vector2(DIRECTION_LEFT, spr_direction.y) # update direction
		
		#Reposition hands
		spr_player_hand_left.position = hand_position_left_default
		spr_player_hand_right.position = hand_position_right_default
		
	if current_state == 'Shooting Rope':
		#Buggy :) but good enough for tonight
		var hand_distance = 240
		var rope_v = Vector2.UP.rotated(rope_shot_angle) * hand_distance
		if spr_direction.x == DIRECTION_RIGHT:
			spr_player_hand_right.position = rope_v
		else:
			spr_player_hand_right.position = Vector2(-rope_v.x, rope_v.y)
