extends Node2D

onready var spawn = $Spawn
var player_scene

func _ready():
	player_scene = load("res://entities/player/Player.tscn")
	
	var player = player_scene.instance() as Player
	call_deferred("add_child", player)
