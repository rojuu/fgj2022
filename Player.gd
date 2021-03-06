extends KinematicBody

class_name Player

signal died(alive_time)

export(float) var move_speed = 30
export(float) var sensitivity = 6.0
export(int) var max_queued_weapon_count = 2

export(float) var speed2x_speed_multiplier = 1.3
export(float) var autofire_delay = 0.1

export(PackedScene) var default_weapon

onready var cur_autofire_delay = 0

onready var velocity: Vector3 = Vector3.ZERO
onready var look_vec: Vector2 = Vector2.ZERO

onready var weapon_point: Position3D = $Camera/WeaponPoint

onready var camera: Camera = $Camera

onready var alive_time = 0
onready var weapon_queue = []

var current_weapon: BaseWeapon

onready var active_powerups = []
onready var autofire_powerup: Powerup = null
onready var explody_powerup: Powerup = null


var speed_fx = {}
var auto_fx = {}
var boom_fx = {}

var rng = RandomNumberGenerator.new()


func _ready():
	speed_fx["left"] = $Camera/SpeedPowerupLeft as Particles
	speed_fx["right"] = $Camera/SpeedPowerupRight as Particles
	auto_fx["left"] = $Camera/AutoPowerupLeft as Particles
	auto_fx["right"] = $Camera/AutoPowerupRight as Particles
	boom_fx["left"] = $Camera/BoomPowerupLeft as Particles
	boom_fx["right"] = $Camera/BoomPowerupLeft2 as Particles

	change_weapon_from_scene(default_weapon)


func change_weapon_from_scene(weapon_scene: PackedScene):
	change_weapon(weapon_scene.instance())


func destroy_current_weapon():
	if is_instance_valid(current_weapon):
		camera.remove_child(current_weapon)
		current_weapon.queue_free()
		current_weapon = null


func eat_current_weapon():
	if is_instance_valid(current_weapon):
		var powerup: Powerup = current_weapon.get_powerup()
		if powerup.type == Powerup.Type.AUTOFIRE:
			if autofire_powerup:
				autofire_powerup.time += powerup.time
			else:
				autofire_powerup = powerup
		elif powerup.type == Powerup.Type.EXPLOSIONS:
			if explody_powerup:
				explody_powerup.time += powerup.time
			else:
				explody_powerup = powerup
		else:
			active_powerups.append(powerup)
		destroy_current_weapon()
		if len(weapon_queue) > 0:
			var weapon = weapon_queue.pop_front()
			change_weapon(weapon)
		playRandomEatSound()


func change_weapon(weapon: BaseWeapon):
	var parent = weapon.get_parent()
	if parent:
		parent.remove_child(weapon)

	current_weapon = weapon
	current_weapon.visible = false
	camera.add_child(current_weapon)
	current_weapon.set_translation(weapon_point.translation)
	current_weapon.set_rotation(weapon_point.rotation)
	current_weapon.set_scale(weapon_point.scale)
	current_weapon.pickup(self)
	yield(get_tree().create_timer(0.05), "timeout")
	if is_instance_valid(current_weapon):
		current_weapon.visible = true



func _input(event):
	if event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		look_vec = mouse_motion.relative


func _process(dt: float):
	alive_time += dt
	
	if !current_weapon and len(weapon_queue) > 0:
		var weapon = weapon_queue.pop_front()
		change_weapon(weapon)

	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	
	var has_speed: bool = false
	
	var speed = move_speed
	var to_remove_powerups = []
	for idx in range(len(active_powerups)):
		var powerup = active_powerups[idx]
		if powerup.time <= 0:
			to_remove_powerups.append(idx)
		else:
			powerup.time -= dt
			match powerup.type:
				Powerup.Type.SPEEDX2:
					has_speed = true
					speed *= speed2x_speed_multiplier
				_: pass
	for i in to_remove_powerups:
		active_powerups.remove(i)
		
	var autofire := false
	if autofire_powerup:
		if autofire_powerup.time <= 0:
			autofire_powerup = null
		else:
			autofire = true
			autofire_powerup.time -= dt

	var explosions := false
	if explody_powerup:
		if explody_powerup.time <= 0:
			explody_powerup = null
		else:
			explosions = true
			explody_powerup.time -= dt
	
	speed_fx["right"].emitting = has_speed
	speed_fx["left"].emitting = has_speed
	
	auto_fx["right"].emitting = autofire
	auto_fx["left"].emitting = autofire
	
	boom_fx["right"].emitting = explosions
	boom_fx["left"].emitting = explosions
	
	velocity -= right * (speed if Input.is_action_pressed("move_left") else 0)
	velocity += right * (speed if Input.is_action_pressed("move_right") else 0)
	
	velocity += forward * (speed if Input.is_action_pressed("move_forwards") else 0)
	velocity -= forward * (speed if Input.is_action_pressed("move_backwards") else 0)
	
	var vp_size := get_viewport().size
	rotate_y((-look_vec.x / vp_size.x) * sensitivity)
	var camera_rot_x: float = camera.rotation.x
	camera_rot_x += (-look_vec.y / vp_size.x) * sensitivity
	camera_rot_x = clamp(camera_rot_x, deg2rad(-89.9), deg2rad(89.9))
	camera.set_rotation(Vector3(camera_rot_x, camera.rotation.y, camera.rotation.z))

	look_vec = Vector2.ZERO

	if is_instance_valid(current_weapon) and (
		Input.is_action_just_pressed("shoot") or
		(autofire and cur_autofire_delay <= 0)
	):
		cur_autofire_delay = autofire_delay
		var vpc := Vector2(vp_size.x / 2, vp_size.y / 2)
		var origin := camera.project_ray_origin(vpc)
		var dir := camera.project_ray_normal(vpc)
		current_weapon.shoot(origin, dir, explosions)

	if cur_autofire_delay > 0:
		cur_autofire_delay -= dt

	if Input.is_action_just_pressed("eat"):
		eat_current_weapon()

	if translation.y < -50.0:
		die()


func die():
	emit_signal("died", alive_time)


func _physics_process(delta):
	velocity.y -= 9.8
	
	move_and_slide(velocity, Vector3(0,1,0))
	
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var enemy: Enemy = collision.collider as Enemy
		if enemy:
			die()

	velocity.x = 0
	velocity.z = 0
	if is_on_floor():
		velocity.y = 0 # reset gravity if we are already on the ground
		

func _on_Area_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	var weapon := area.owner as BaseWeapon
	if weapon:
		if current_weapon == null:
			change_weapon(weapon)
		elif len(weapon_queue) < max_queued_weapon_count and weapon != current_weapon:
			weapon.visible = false
			weapon_queue.append(weapon)

func playRandomEatSound():
	var random_int = rng.randi_range(1, 4)               # pick a valid random number
	var snd = get_node("Eat"+str(random_int))  # select a sound
	snd.play()
	#yield(get_tree().create_timer(0.2), "timeout")
	#snd.stop()


