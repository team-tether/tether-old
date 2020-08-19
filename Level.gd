extends Node2D
class_name Level

export var fix_camera_x = true
export var fix_camera_y = true

export var limit_offset = Vector2.ZERO

var death_particles_scene = preload("res://entities/DeathParticles.tscn")

onready var player: Player = $Player
onready var camera: Camera2D = $CameraTarget/Camera
onready var camera_target: Position2D = $CameraTarget
onready var terrain: Polygon2D = $Terrain

func _ready():
	var border = terrain.invert_border if terrain.invert_enable else 0.0
	var padding = limit_offset + (Vector2.ONE * border)
	var terrain_bounds: Rect2 = Util.get_bounding_rect(terrain.polygon, padding)

	if (camera.position != Vector2(0,0)):
		camera.position.x = 0; #Camera breaks if it's not at [0,0]
		camera.position.y = 0;
		print("Camera position reset")
	camera.limit_top = int(terrain_bounds.position.y)
	camera.limit_left = int(terrain_bounds.position.x)
	camera.limit_bottom = int(terrain_bounds.end.y)
	camera.limit_right = int(terrain_bounds.end.x)

	if player:
		if !fix_camera_x:
			camera_target.position.x = player.position.x
		if !fix_camera_y:
			camera_target.position.y = player.position.y
	camera.align()

func _process(_delta):
	if player:
		if !fix_camera_x:
			camera_target.position.x = player.position.x
		if !fix_camera_y:
			camera_target.position.y = player.position.y

	if player and Input.is_action_just_pressed("respawn"):
		print("User forced respawn with input_key")
		die()
	
	#Change levels with brackets: Next: "{" Previous: "}"
	if player and Input.is_action_just_pressed("editor_next_level"):
		next_level()
	if player and Input.is_action_just_pressed("editor_previous_level"):
		next_level(true)

func next_level(backwards = false):
	var next_level_path = Util.find_next_level_filename(filename, backwards)
	if next_level_path:
		SceneChanger.change_scene(next_level_path)

func remove_player():
	player.queue_free()
	get_node("Rope").queue_free()

func win():
	print("good job!")
	remove_player()
	yield(get_tree().create_timer(0.5), "timeout")
	next_level()

func die():
	spawn_death_particles()
	remove_player()
	yield(get_tree().create_timer(0.5), "timeout")
	SceneChanger.change_scene(filename)
	
func spawn_death_particles():
	var death_particles: Particles2D = death_particles_scene.instance()
	death_particles.position = player.position
	death_particles.emitting = true
	var mat = death_particles.process_material as ParticlesMaterial
	var norm_vel = player.prev_velocity.normalized()
	mat.direction = Vector3(norm_vel.x, norm_vel.y, 0)
	mat.initial_velocity = player.prev_velocity.length() * 0.5
	add_child(death_particles)
