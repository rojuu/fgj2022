extends BaseEnemy

export var speed = 10
export var flying = false
export var gravity = 9.8
var velocity = Vector3.ZERO
var gravity_velocity = 0
var player
var player_position
var forward

func _ready():
	player =  get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	player_position = player.translation
	look_at(player_position, Vector3.UP)
	forward = -global_transform.basis.z
	if(flying):
		forward.y = 0
	velocity = forward * speed
	if (!flying):
			gravity_velocity -= gravity
	velocity.y += gravity_velocity
	move_and_slide(velocity, Vector3(0,1,0))
	if is_on_floor():
		gravity_velocity = 0
