extends KinematicBody

export var move_speed = 30
export var sensitivity = 6.0

onready var velocity: Vector3 = Vector3.ZERO
onready var look_vec: Vector2 = Vector2.ZERO

onready var camera := $Camera

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
	if Input.is_action_just_pressed("shoot"):
		print("BANG!")

	# Kill if falls off the platform
	if translation.y < -50.0:
		print("DEAD")


func _physics_process(delta):
	velocity.y -= 9.8
	
	move_and_slide(velocity, Vector3(0,1,0))
	velocity.x = 0
	velocity.z = 0
	if is_on_floor():
		velocity.y = 0
