extends KinematicBody

signal died

export(float) var move_speed = 30
export(float) var sensitivity = 6.0

export(PackedScene) var default_weapon

onready var velocity: Vector3 = Vector3.ZERO
onready var look_vec: Vector2 = Vector2.ZERO

onready var weapon_point: Position3D = $Camera/WeaponPoint

onready var camera: Camera = $Camera

var current_weapon: BaseWeapon

func change_weapon_from_scene(weapon_scene: PackedScene):
	change_weapon(weapon_scene.instance())


func destroy_current_weapon():
	if current_weapon != null:
		camera.remove_child(current_weapon)
		current_weapon.queue_free()
		current_weapon = null


func eat_current_weapon():
	# TODO give some yiihaws
	destroy_current_weapon()


func change_weapon(weapon: BaseWeapon):
	var parent = weapon.get_parent()
	if parent:
		parent.remove_child(weapon)

	current_weapon = weapon
	camera.add_child(current_weapon)
	current_weapon.set_translation(weapon_point.translation)
	current_weapon.set_rotation(weapon_point.rotation)
	current_weapon.set_scale(weapon_point.scale)
	current_weapon.pickup(self)


func _ready():
	change_weapon_from_scene(default_weapon)


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		look_vec = mouse_motion.relative


func _process(dt: float):
	# Movement
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	
	velocity -= right * (move_speed if Input.is_action_pressed("move_left") else 0)
	velocity += right * (move_speed if Input.is_action_pressed("move_right") else 0)
	
	velocity += forward * (move_speed if Input.is_action_pressed("move_forwards") else 0)
	velocity -= forward * (move_speed if Input.is_action_pressed("move_backwards") else 0)
	
	# Mouse look
	var vp_size := get_viewport().size
	rotate_y((-look_vec.x / vp_size.x) * sensitivity)
	var camera_rot_x: float = camera.rotation.x
	camera_rot_x += (-look_vec.y / vp_size.x) * sensitivity
	camera_rot_x = clamp(camera_rot_x, deg2rad(-89.9), deg2rad(89.9))
	camera.set_rotation(Vector3(camera_rot_x, camera.rotation.y, camera.rotation.z))

	look_vec = Vector2.ZERO

	# Shooting
	if Input.is_action_just_pressed("shoot") and current_weapon:
		var vpc := Vector2(vp_size.x / 2, vp_size.y / 2)
		var origin := camera.project_ray_origin(vpc)
		var dir := camera.project_ray_normal(vpc)
		current_weapon.shoot(origin, dir)

	if Input.is_action_just_pressed("eat"):
		eat_current_weapon()

	# Kill if falls off the platform
	if translation.y < -50.0:
		print("DEAD")


func _physics_process(delta):
	velocity.y -= 9.8
	
	move_and_slide(velocity, Vector3(0,1,0))
	
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var enemy: BaseEnemy = collision.collider as BaseEnemy
		if enemy:
			emit_signal("died")

	velocity.x = 0
	velocity.z = 0
	if is_on_floor():
		velocity.y = 0 # reset gravity if we are already on the ground
		

func _on_Area_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	var weapon := area.owner as BaseWeapon
	if weapon:
		if current_weapon == null:
			change_weapon(weapon)

