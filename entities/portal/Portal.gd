extends Node2D

onready var entrance: PortalSide = $Entrance
onready var exit: PortalSide = $Exit

func enter_portal(other_side: PortalSide, player: Player):
	var normal = Vector2.DOWN.rotated(other_side.global_rotation)
	player.states.go_to("Falling")
	player.is_shooting_rope = false
	player.position = other_side.global_position + normal * (player.collider_height() / 2)
	player.velocity = player.velocity.rotated(player.velocity.angle_to(normal))

func can_enter_portal(side: PortalSide, player: Player):
	var normal = Vector2.DOWN.rotated(side.global_rotation)
	var angle = abs(normal.angle_to(player.velocity))
	return angle > PI / 2

func _on_Entrance_body_entered(body):
	if body is Player && can_enter_portal(entrance, body):
		enter_portal(exit, body as Player)

func _on_Exit_body_entered(body):
	if body is Player && can_enter_portal(exit, body):
		enter_portal(entrance, body as Player)
