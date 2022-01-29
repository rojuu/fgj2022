extends Spatial

class_name BaseWeapon

onready var players = get_tree().get_nodes_in_group("Player")

func shoot(origin: Vector3, dir: Vector3):
	pass
	#var ray_result = get_world().direct_space_state.intersect_ray(origin, dir * 10000, [self] + players)
	#var owners = ray_result.collision.get_shape_owners()
