extends State

export var drag = Vector2.ONE

func on_physics_process(player, _delta):
	player.body.velocity *= drag
	player.body.velocity = player.body.move_and_slide_with_snap(player.body.velocity, Vector2.DOWN, Vector2.UP)
