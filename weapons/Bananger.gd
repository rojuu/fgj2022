extends BaseWeapon

func shoot(origin: Vector3, dir: Vector3):
	var ray_result = get_world().direct_space_state.intersect_ray(origin, dir * 10000, [self] + players)
