extends RigidBody

class_name BaseWeapon

export(float) var damage = 3 

onready var players = get_tree().get_nodes_in_group("Player")

onready var running_time: float = 0
onready var picked_up: bool = false


func _ready():
	var t := Thread.new()
	t.start(self, "build_sfxr_buffer")
	set_scale(Vector3.ONE * 10)


func build_sfxr_buffer():
	var p := $SfxrStreamPlayer as SfxrStreamPlayer
	p._build_buffer()


func pickup(owner):
	sleeping = true
	var c:= $CollisionShape as CollisionShape
	c.disabled = true
	picked_up = true
	var area: Area = $Area as Area
	area.monitorable = false


func shoot(origin: Vector3, dir: Vector3):
	var p := $SfxrStreamPlayer as SfxrStreamPlayer
	p.play_sfx()
	var ray_result = get_world().direct_space_state.intersect_ray(origin, dir * 10000, [self] + players)
	var enemy: Enemy = ray_result.collider as Enemy
	if enemy != null:
		enemy.take_damage(damage)


func _process(delta):
	if picked_up:
		$Sprite3D.translation.y = 0
		$Sprite3D.rotation.y = 0
		return
	running_time += delta
	$Sprite3D.translation.y = 0.5 + sin(running_time * 3) * 0.5
	$Sprite3D.rotate_y(-delta * 2)
	
