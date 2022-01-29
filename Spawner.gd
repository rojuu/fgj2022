extends Node

export var spawn_time_min = 1.0
export var spawn_time_max = 1.0

export(Array, PackedScene) var enemy_templates 

onready var spawn_points = get_tree().get_nodes_in_group("SpawnPoint")

onready var rng := RandomNumberGenerator.new()

func random_element_from_array(arr):
	var idx = rng.randi_range(0, len(arr)-1)
	return arr[idx]

func get_random_spawn_point() -> SpawnPoint:
	var spawn_point: SpawnPoint =  random_element_from_array(spawn_points)
	return spawn_point

func spawn_loop():
	while true:
		var spawn_time_delay = rng.randf_range(spawn_time_min, spawn_time_max)
		yield(get_tree().create_timer(spawn_time_delay), "timeout")
		
		var enemy: Spatial = random_element_from_array(enemy_templates).instance()
		get_tree().root.add_child(enemy)
		enemy.set_translation(get_random_spawn_point().translation)

func _ready():
	spawn_loop()


