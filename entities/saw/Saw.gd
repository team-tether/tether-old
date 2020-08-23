tool
extends Node2D

func _on_Area2D_body_entered(body):
	if body is Player:
		var level = get_tree().root.get_node("Level") as Level
		level.die()
