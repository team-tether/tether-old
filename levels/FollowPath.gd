extends PathFollow2D

export var duration = 1.0

var backwards = false

func _physics_process(delta):
	unit_offset += (delta / duration) * (-1 if backwards else 1)
	
	if unit_offset <= 0:
		backwards = false
	if unit_offset >= 1:
		backwards = true
	
