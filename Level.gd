extends Node2D
class_name Level

var player_scene = preload("res://entities/player/Player.tscn")
var death_particles_scene = preload("res://entities/DeathParticles.tscn")

var player: Player
onready var spawn = $Spawn

func _ready():
	spawn_player()

func _process(_delta):
	if player and Input.is_action_just_pressed("respawn"):
		die()

func win():
	print("good job!")
	remove_player()
	spawn_player()
	
func remove_player():
	player.free()
	get_node("Rope").free()

func die():
	spawn_death_particles()
	remove_player()
	yield(get_tree().create_timer(0.25), "timeout")
	spawn_player()
	
func spawn_player():
	player = player_scene.instance()
	player.position = spawn.position
	add_child(player)
	
func spawn_death_particles():
	var death_particles: Particles2D = death_particles_scene.instance()
	death_particles.position = player.position
	death_particles.emitting = true
	var mat = death_particles.process_material as ParticlesMaterial
	var norm_vel = player.prev_velocity.normalized()
	mat.direction = Vector3(norm_vel.x, norm_vel.y, 0)
	mat.initial_velocity = player.prev_velocity.length() * 0.5
	get_tree().root.add_child(death_particles)
	yield(get_tree().create_timer(1), "timeout")
	death_particles.queue_free()
