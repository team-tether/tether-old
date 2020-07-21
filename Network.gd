extends Node

const MAX_PLAYERS = 10
const PORT = 1337
var player_scene
var players = []
var connected = false

func _ready():
	player_scene = preload("res://entities/player/Player.tscn")
	get_tree().connect("connected_to_server", self, "_connected_ok")

func on_host_game():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(host)
	
	_connected_ok()
 
func on_join_game(ip):
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, PORT)
	get_tree().set_network_peer(host)

func _connected_ok():
	connected = true
	rpc("register_player", get_tree().get_network_unique_id())
	register_player(get_tree().get_network_unique_id())

remote func register_player(player_id):
	var root = get_tree().get_root()
	var spawn = root.get_node("Game/Spawn")
	var player = player_scene.instance() as Player
	player.set_network_master(player_id)
	player.name = str(player_id)
	player.call_deferred("set_body_position", spawn.position)
	root.add_child(player)
	# if I'm the server I inform the new connected player about the others
	if get_tree().get_network_unique_id() == 1:
		if player_id != 1:
			for i in players:
				rpc_id(player_id, "register_player", i)
	players.append(player_id)
