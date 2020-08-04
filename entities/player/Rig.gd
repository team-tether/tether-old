extends Node2D
tool
class_name Rig

export var flip_h: bool setget set_flip_h,get_flip_h
export var flip_v: bool setget set_flip_v,get_flip_v

var textures: RigTextures setget set_rig_textures

onready var body: Sprite = $Body
onready var head: Sprite = $Head
onready var left_hand: Sprite = $LeftHand
onready var right_hand: Sprite = $RightHand

onready var hand_position_left_default = left_hand.position
onready var hand_position_right_default = right_hand.position

var player
var current_state = ''



func _ready():
	player = get_parent()
	#z-index sorting
	var z_index_starting_position = 1000
	body.z_index = z_index_starting_position #Bottom
	head.z_index = z_index_starting_position + 1
	left_hand.z_index = z_index_starting_position + 2
	right_hand.z_index = z_index_starting_position + 3 #Top

func set_rig_textures(t: RigTextures):
	body.texture = t.body
	head.texture = t.head
	left_hand.texture = t.left_hand
	right_hand.texture = t.right_hand
	textures = t

func set_flip_h(flipped):
	scale.x = abs(scale.x) * (-1 if flipped else 1)
	
func get_flip_h():
	return scale.x < 0
	
func set_flip_v(flipped):
	scale.y = abs(scale.y) * (-1 if flipped else 1)
	
func get_flip_v():
	return scale.y < 0
	
func _physics_process(delta):
	match current_state:
		"Falling":
			rotation += player.angular_velocity * delta

func _process(_delta):
	match current_state:
		"Falling":
			#Reposition hands
			left_hand.position = Vector2(-100,-100)
			right_hand.position = Vector2(100,-100)
		"Grounded":
			rotation = 0
			#Reposition hands
			left_hand.position = Vector2(-100,75)
			right_hand.position = Vector2(100,75)
		"Tethered":
			#Rotate / flip body based on players position compared to rope end point
			var to_pivot = player.position - player.rope.pivot() #duplicate code - bad practice
			var tolerance = 8 #Just stops the character from shaking if its not swinging much
			var moving_right = (player.position.x - tolerance) < player.rope.pivot().x #player.velocity.x > 0
			rotation = -to_pivot.angle_to(Vector2.LEFT if moving_right else Vector2.RIGHT)
			set_flip_h(!moving_right)
			#Reposition hands
			left_hand.position = hand_position_left_default
			right_hand.position = hand_position_right_default
		"Shooting Rope":
			var hand_distance = 300
			#This is currently broken, it will have to rotate based on the direction of the rope relative to the current angle of the player
			#Haven't figured out how to calculate it yet because I don't know Godots built in functions
			var rope_v = Vector2.UP.rotated(player.rope_shot_angle) * hand_distance
			right_hand.position = rope_v
			

