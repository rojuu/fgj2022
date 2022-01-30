extends RigidBody

class_name BaseWeapon

export(float) var damage = 3 

export(Powerup.Type) var to_give_powerup = Powerup.Type.NONE


onready var players = get_tree().get_nodes_in_group("Player")

onready var running_time: float = 0
onready var picked_up: bool = false

onready var rng := RandomNumberGenerator.new()
onready var shootvfx = get_node("ShootVFX")

var sfxr_mutex
var sfxr_player: SfxrStreamPlayer 

var stop_everything = false

func _ready():
	rng.randomize()

	sfxr_mutex = Mutex.new()
	sfxr_player = $SfxrStreamPlayer
	var t := Thread.new()
	t.start(self, "build_sfxr_buffer")
	set_scale(Vector3.ONE * 10)
	shootvfx.emitting = false


func build_sfxr_buffer():
	sfxr_mutex.lock()
	sfxr_player._build_buffer()
	sfxr_mutex.unlock()


func get_texture():
	var sprite := $Sprite3D as Sprite3D
	return sprite.texture


func get_powerup():
	var pu = Powerup.new()
	match(to_give_powerup):
		Powerup.Type.SPEEDX2:
			pu.type = Powerup.Type.SPEEDX2
			pu.time = 5
		Powerup.Type.AUTOFIRE:
			pu.type = Powerup.Type.AUTOFIRE
			pu.time = 5
		Powerup.Type.EXPLOSIONS:
			pu.type = Powerup.Type.EXPLOSIONS
			pu.time = 4
		_: pass
	return pu

func pickup(owner):
	sleeping = true
	var c:= $CollisionShape as CollisionShape
	c.disabled = true
	picked_up = true
	$Sprite3D.translation.y = 0
	$Sprite3D.rotation.y = 0
	var area: Area = $Area as Area
	area.monitorable = false


func shoot(origin: Vector3, dir: Vector3):
	shootvfx.restart()
	sfxr_mutex.lock()
	sfxr_player.play_sfx()
	sfxr_mutex.unlock()
	var weapons = get_tree().get_nodes_in_group("Weapon")
	var ray_result = get_world().direct_space_state.intersect_ray(origin, dir * 10000, [self] + players + weapons)
	var enemy: Enemy = ray_result.collider as Enemy
	if enemy != null:
		enemy.take_damage(damage)


func _process(delta):
	if picked_up:
		return
	running_time += delta
	$Sprite3D.translation.y = 0.5 + sin(running_time * 3) * 0.5
	$Sprite3D.rotate_y(-delta * 2)
	
