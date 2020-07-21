extends Node

func _on_Death_body_entered(body):
	var parent = body.get_parent()
	if parent is Player:
		var player = parent as Player
		player.die()
	pass # Replace with function body.
