extends Node

var level: Level

func _ready():
	level = get_tree().root.get_node("Level") as Level
	
	Console.addCommand('level', self, 'load_level_by_name')\
		.setDescription('Loads a level by name')\
		.addArgument('name', TYPE_STRING)\
		.register()

	Console.addCommand('levels', self, 'list_levels')\
		.setDescription('Lists all levels')\
		.register()
		
	Console.addCommand('quit', self, 'quit')\
		.setDescription('Quits the game')\
		.register()
		
	Console.addCommand('toggle_fullscreen', self, 'toggle_fullscreen')\
		.setDescription('Toggles fullscreen')\
		.register()
		
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		quit()
		
	if Input.is_action_just_pressed("fullscreen_toggle"):
		toggle_fullscreen()

func quit():
	get_tree().quit()
	
func toggle_fullscreen():
	OS.window_fullscreen = !OS.window_fullscreen

func load_level_by_name(name):
	SceneChanger.change_scene("res://levels/%s.tscn" % name)
	
func list_levels():
	var filenames = list_files_in_directory("res://levels/")
	for filename in filenames:
		Console.writeLine(filename.replace(".tscn", ""))
	

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
