extends Node2D
tool
class_name ElectricityLine

var player
var after_effects
var z_index_base = 2000


func _ready():
	player = get_parent().get_parent().get_node("Player") #Can't find a better way to do this lol
	after_effects = get_parent()
	after_effects.set_z_index(z_index_base)

func _draw():
	#Draw call for custom 2d art: https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html
	if player:
		if player.rig.current_state == "Tethered":
			var start_position = Vector2(player.position.x, player.position.y)
			var end_position = Vector2(player.rope.pivot().x, player.rope.pivot().y)
			var color = Color(0, 0, 0)
			var width = 2
			draw_electricity_line(start_position, end_position, color, width)
	
	#Does nothing for now, need to work out all the math, this just for my own reference
	#Pivot points
	#var points_count = 32
	#var points_position = PoolVector2Array()
	#var random_angle = 2
	#var angle_point = deg2rad(random_angle)
	#points_position.push_back(start_position + Vector2(cos(angle_point), sin(angle_point)))
	#for i in range(points_count + 1):

#Electricity experiment
func draw_electricity_line(start_position, end_position, color, width):
	var points_line = PoolVector2Array()
	draw_line(start_position, end_position, color, width)

func _process(_delta):
	update() #Calls the draw function every frame
