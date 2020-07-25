extends State

export var drag = Vector2.ONE

func on_physics_process(player, _delta):
	player.velocity *= drag
	player.velocity = player.move_and_slide_with_snap(player.velocity, Vector2.DOWN, Vector2.UP)
