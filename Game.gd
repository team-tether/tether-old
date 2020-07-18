extends Node

func _ready():
	print("unique id: ",get_tree().get_network_unique_id())


func _on_Death_body_entered(body):
	var parent = body.get_parent()
	if parent is Player:
		var player = parent as Player
		player.die()
	pass # Replace with function body.
