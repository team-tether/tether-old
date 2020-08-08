tool
extends Path2D

export(Array, PackedScene) var choices: Array
export var distance = 8

func _ready():
	spawn()
	if Engine.editor_hint:
		curve.connect("changed", self, "curve_changed")
	
func curve_changed():
	for child in get_children():
		remove_child(child)
	spawn()
	
func spawn():
	var length = curve.get_baked_length()
	
	var num = round(length / distance)
	for i in range(num):
		var path_follow = PathFollow2D.new()
		var choice = choices[randi() % choices.size()]
		var instance = choice.instance()
		path_follow.add_child(instance)
		path_follow.offset = i * distance
		add_child(path_follow)
