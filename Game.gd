extends Node

onready var level: Node = $Level

func unload_level():
	if !level:
		Console.writeLine("No current level");
		return
		
	level.free()
		
func reload_level():
	if !level:
		Console.writeLine("No current level");
		return
		
	load_level_by_filename(level.filename)
	
func load_level_by_filename(filename):
	unload_level()
	
	level = load(filename).instance()
	add_child(level)

func load_level_by_name(name):
	load_level_by_filename("res://levels/%s.tscn" % name)
	
func list_levels():
	var filenames = list_files_in_directory("res://levels/")
	for filename in filenames:
		Console.writeLine(filename.replace(".tscn", ""))
	

func _ready():
	Console.addCommand('load_level', self, 'load_level_by_name')\
		.setDescription('Loads a level by name')\
		.addArgument('name', TYPE_STRING)\
		.register()
		
	Console.addCommand('unload_level', self, 'unload_level')\
		.setDescription('Unloads the current level')\
		.register()
		
	Console.addCommand('reload_level', self, 'reload_level')\
		.setDescription('Reloads the current level')\
		.register()
		
	Console.addCommand('list_levels', self, 'list_levels')\
		.setDescription('Lists all levels')\
		.register()

func _on_Death_body_entered(body):
	var parent = body.get_parent()
	if parent is Player:
		var player = parent as Player
		player.die()
	pass # Replace with function body.
	
	
func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files

