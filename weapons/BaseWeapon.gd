extends Spatial

class_name BaseWeapon

export(float) var damage = 3 

onready var players = get_tree().get_nodes_in_group("Player")

onready var running_time: float = 0
onready var picked_up: bool = false
var original_translation

func _ready():
	original_translation = translation
	set_scale(Vector3.ONE * 10)


func pickup(owner):
	picked_up = true
	var area: Area = $Area as Area
	area.monitorable = false


func shoot(origin: Vector3, dir: Vector3):
	var ray_result = get_world().direct_space_state.intersect_ray(origin, dir * 10000, [self] + players)
	var enemy: BaseEnemy = ray_result.collider as BaseEnemy
	if enemy != null:
		enemy.take_damage(damage)


func _process(delta):
	if picked_up: return
	running_time += delta
	translation.y = original_translation.y + sin(running_time * 3) * 2
	rotate_y(-delta * 2)
	
