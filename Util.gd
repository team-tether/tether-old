class_name Util

const MAX_COORD = pow(2, 31)- 1
const MIN_COORD = -MAX_COORD

static func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(path + file)
	dir.list_dir_end()
	return files

static func find_next_level_filename(current_level_filename, backwards = false):
	var level_filenames = list_files_in_directory("res://levels/")
	var current_level_prefix = current_level_filename.substr(0, current_level_filename.find("_"))
	var parts = current_level_prefix.split("-")
	var world_num = int(parts[0])
	var level_num = int(parts[1])

	var offset = -1 if backwards else 1
	var next_level_prefix = "%s-%s" % [world_num, level_num + offset]
	var next_level_filename = find_in_array(level_filenames, next_level_prefix)

	if next_level_filename:
		return next_level_filename

	next_level_prefix = "%s-%s" % [world_num + offset, level_num]
	next_level_filename = find_in_array(level_filenames, next_level_prefix)

	if next_level_filename:
		return next_level_filename
		
	return find_in_array(level_filenames, "1-1")

static func find_in_array(array, substring):
	for s in array:
		if substring in s:
			return s

static func min_vector(a, b):
	return Vector2(min(a.x, b.x), min(a.y ,b.y))

static func max_vector(a, b):
	return Vector2(max(a.x, b.x), max(a.y, b.y))
		
static func get_bounding_rect(points, padding = Vector2.ZERO):
	var min_vec = Vector2(MAX_COORD, MAX_COORD)
	var max_vec = Vector2(MIN_COORD, MIN_COORD)
	for p in points:
		min_vec = min_vector(min_vec, p)
		max_vec = max_vector(max_vec, p)
	min_vec -= padding
	max_vec += padding
	return Rect2(min_vec, max_vec - min_vec)
