extends Node2D

onready var entrance: PortalSide = $Entrance
onready var exit: PortalSide = $Exit

var disable_after_exiting_timeout = 0.25

func enter_portal(other_side: PortalSide, player: Player):
	other_side.enabled = false
	
	var normal = Vector2.DOWN.rotated(other_side.rotation)
	player.states.go_to("Falling")
	player.is_shooting_rope = false
	player.position = other_side.position + normal * (player.collider_height() / 2)
	player.velocity = player.velocity.rotated(player.velocity.angle_to(normal))

	yield(get_tree().create_timer(disable_after_exiting_timeout), "timeout")
	other_side.enabled = true

func _on_Entrance_body_entered(body):
	if entrance.enabled && body is Player:
		enter_portal(exit, body as Player)

func _on_Exit_body_entered(body):
	if exit.enabled && body is Player:
		enter_portal(entrance, body as Player)
