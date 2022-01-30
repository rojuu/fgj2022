extends Node

export(float) var spawn_time_min = 1.0
export(float) var spawn_time_max = 1.0

export(Array, PackedScene) var enemy_templates 

onready var spawn_points = get_tree().get_nodes_in_group("SpawnPoint")

onready var rng := RandomNumberGenerator.new()
onready var player: Node = get_tree().get_nodes_in_group("Player")[0]

var stop_everything = false

func _ready():
	rng.randomize()
	player.connect("died", self, "_on_Player_died")
	
	spawn_enemy()
	spawn_loop()
	
func _on_Player_died(alive_time):
	stop_everything = true
	pass

func random_element_from_array(arr):
	var idx = rng.randi_range(0, len(arr)-1)
	return arr[idx]


func get_random_spawn_point() -> SpawnPoint:
	var spawn_point: SpawnPoint =  random_element_from_array(spawn_points)
	return spawn_point


func spawn_enemy():
	if stop_everything:
		return
	var enemy: Spatial = random_element_from_array(enemy_templates).instance()
	add_child(enemy)
	enemy.set_translation(get_random_spawn_point().translation)


func spawn_loop():
	while !stop_everything:
		var spawn_time_delay = rng.randf_range(spawn_time_min, spawn_time_max)
		yield(get_tree().create_timer(spawn_time_delay), "timeout")
		
		spawn_enemy()


