extends Node2D

onready var spawn = $Spawn
var player_scene

func _ready():
	player_scene = preload("res://entities/player/Player.tscn")
	
	var player = player_scene.instance() as Player
	player.set_network_master(0)
#	player.name = str(player_id)

	call_deferred("add_child", player)
