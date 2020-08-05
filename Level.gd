extends Node2D
class_name Level

export(String, FILE, "*.tscn") var next_level_path
export var fixed_camera = false

var death_particles_scene = preload("res://entities/DeathParticles.tscn")

onready var player: Player = $Player
onready var camera: Camera2D = $CameraTarget/Camera
onready var camera_target: Position2D = $CameraTarget

func _ready():
	camera_target.position = player.position
	camera.align()

func _process(_delta):
	if player and !fixed_camera:
		camera_target.position = player.position

	if player and Input.is_action_just_pressed("respawn"):
		print("User forced respawn with input_key")
		die()
	
	#Change levels with brackets: Next: "{" Previous: "}"
	if player and Input.is_action_just_pressed("editor_next_level"):
		print("User changed to next level with input_key")
		win()
	if player and Input.is_action_just_pressed("editor_previous_level"):
		print("NOT IMPLEMENTED - User changed to previous level with input_key")
		#Currently does nothing - Not sure how to get current level or change to previous

func win():
	print("good job!")
	remove_player()

	if next_level_path:
		SceneChanger.change_scene(next_level_path, 1.0)
	
func remove_player():
	player.queue_free()
	get_node("Rope").queue_free()

func die():
	spawn_death_particles()
	remove_player()
	SceneChanger.change_scene(filename, 0.5)
	
func spawn_death_particles():
	var death_particles: Particles2D = death_particles_scene.instance()
	death_particles.position = player.position
	death_particles.emitting = true
	var mat = death_particles.process_material as ParticlesMaterial
	var norm_vel = player.prev_velocity.normalized()
	mat.direction = Vector3(norm_vel.x, norm_vel.y, 0)
	mat.initial_velocity = player.prev_velocity.length() * 0.5
	add_child(death_particles)
