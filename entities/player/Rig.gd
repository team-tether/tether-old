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
	match current_state:
		"Falling":
			rotation += player.angular_velocity * delta

func _process(_delta):
	#Switch statement
	match current_state:
		"Falling":
			pass
		"Grounded":
			rotation = 0
			pass
		"Tethered":
			#Rotate / flip body based on players position compared to rope end point
			var to_pivot = player.position - player.rope.pivot() #duplicate code - bad practice
			var tolerance = 8 #Just stops the character from shaking if its not swinging much
			var moving_right = (player.position.x - tolerance) < player.rope.pivot().x #player.velocity.x > 0
			rotation = -to_pivot.angle_to(Vector2.LEFT if moving_right else Vector2.RIGHT)
			set_flip_h(!moving_right)
		"Shooting Rope":
			pass
			

