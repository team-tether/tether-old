extends Node2D
tool
class_name Rig

export var flip_h: bool setget set_flip_h,get_flip_h
export var flip_v: bool setget set_flip_v,get_flip_v

var textures: RigTextures setget set_rig_textures

onready var ball: Sprite = $Ball
onready var glow: Sprite = $Glow

var player
var current_state = ''
var default_scale = scale
var player_velocity = Vector2(0,0)
var facing_right = true

func _ready():
	player = get_parent()
	#z-index sorting
	var z_index_starting_position = 1000
	glow.z_index = z_index_starting_position #Bottom
	ball.z_index = z_index_starting_position + 1 #Top
	glow.visible = false

func set_rig_textures(t: RigTextures):
	ball.texture = t.ball
	glow.texture = t.glow

func set_flip_h(flipped):
	scale.x = abs(scale.x) * (-1 if flipped else 1)
	
func get_flip_h():
	return scale.x < 0
	
func set_flip_v(flipped):
	scale.y = abs(scale.y) * (-1 if flipped else 1)
	
func get_flip_v():
	return scale.y < 0
	
func _physics_process(delta):
	scale = default_scale #Default
	
	match current_state:
		"Falling":
			rotation += player.angular_velocity * delta
			var velocity_y = clamp(player.velocity.y, 1, 20)
			#var velocity_x = clamp(player.velocity.x, 1, 20)
			scale.y = default_scale.y * (1 + ((velocity_y / 20)*0.1))
			scale.x = default_scale.x * (1 - ((velocity_y / 20)*0.1))
		"Shooting Rope":
			rotation += player.angular_velocity * delta
			var velocity_y = clamp(player.velocity.y, 1, 20)
			#var velocity_x = clamp(player.velocity.x, 1, 20)
			scale.y = default_scale.y * (1 + ((velocity_y / 20)*0.1))
			scale.x = default_scale.x * (1 - ((velocity_y / 20)*0.1))

func _process(_delta):
		
	#Switch statement
	match current_state:
		"Falling":
			set_flip_h(!sign(player.velocity.x) < 0)
			var input_direction = player.input_direction()
			if (input_direction.x != 0):
				set_flip_h(!sign(input_direction.x) < 0)
			pass
		"Grounded":
			rotation = 0
			var input_direction = player.input_direction()
			if (input_direction.x > 0):
				set_flip_h(!sign(input_direction.x) < 0)
		"Tethered":
			#Rotate / flip body based on players position compared to rope end point
			var to_pivot = player.position - player.rope.pivot() #duplicate code - bad practice
			var tolerance = 8 #Just stops the character from shaking if its not swinging much
			var moving_right = (player.position.x - tolerance) < player.rope.pivot().x #player.velocity.x > 0
			var adjust_angle = deg2rad(90)
			if (moving_right == true):
				adjust_angle = -deg2rad(90)
			rotation = -to_pivot.angle_to(Vector2.LEFT if moving_right else Vector2.RIGHT) - adjust_angle
			
			var input_direction = player.input_direction()
			if (input_direction.x != 0):
				facing_right = sign(input_direction.x)
				set_flip_h(!sign(input_direction.x) < 0)
			else:
				set_flip_h(!moving_right)
		"Shooting Rope":
			#Rotate / flip body based on players position compared to rope end point
			var moving_right = rad2deg(player.rope_shot_angle) > 0 #player.velocity.x > 0
			var adjust_angle = deg2rad(90)
			if (moving_right == true):
				adjust_angle = -deg2rad(90)
				set_flip_h(true)
			else:
				set_flip_h(false)
			rotation = -player.rope_shot_angle - adjust_angle
			
			

