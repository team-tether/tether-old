tool
extends Area2D

func _on_body_entered(body):
	if body is Player:
		var level = get_tree().root.get_node("Level") as Level
		level.die()
