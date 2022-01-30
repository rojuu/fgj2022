extends KinematicBody

class_name Enemy

var health = 6
var speed = 30
export(bool) var flying = false
export(float) var gravity = 9.8

export(float) var weapon_drop_chance = 0.3
export(Array, PackedScene) var drop_weapons

onready var dying := false

onready var velocity := Vector3.ZERO
onready var gravity_velocity = 0
onready var player: Node = get_tree().get_nodes_in_group("Player")[0]

onready var rng := RandomNumberGenerator.new()

onready var hitvfx = get_node("HitVFX")
onready var deathvfx = get_node("DeathVFX")
onready var explodevfx = get_node("ExplodeVFX")

onready var enemies_in_explode_range = []

var audiorng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	hitvfx.emitting = false
	deathvfx.emitting = false
	explodevfx.emitting = false
	audiorng.randomize()
	var ambientsfx = get_node("AmbientSound")
	ambientsfx.play()
	if(flying):
		health = 3
		speed = 45


func random_element_from_array(arr):
	var idx = rng.randi_range(0, len(arr)-1)
	return arr[idx]


func drop_random_weapon():
	if len(drop_weapons) == 0:
		return
	var weapon_scene = random_element_from_array(drop_weapons)
	var weapon := weapon_scene.instance() as RigidBody
	get_parent().add_child(weapon)
	weapon.translation = translation


func take_damage(damage: float, should_do_explody: bool):
	if dying:
		return
	health -= damage
	
	if should_do_explody:
		$ExplodeVFX.restart()
		for e in enemies_in_explode_range:
			e.take_damage(6, false)
	
	if health <= 0:
		dying = true
		deathvfx.restart()
	var sprite := $Sprite3D as Sprite3D
	sprite.modulate = Color.red
	hitvfx.restart()
	playRandomHitSound()
	#$AudioStreamPlayer3D.stop()
	sprite.modulate = Color.white
	
	if dying:
		if rng.randf() < weapon_drop_chance:
			drop_random_weapon()
		$Sprite3D.visible = false
		$CollisionShape.disabled = true
		yield(get_tree().create_timer(2), "timeout")
		queue_free()


func _process(delta):
	$DebugViewport/Control/NumberOfEnemiesInExplodeRange.text = String(len(enemies_in_explode_range))


func _physics_process(delta):
	if dying:
		return

	look_at(player.translation, Vector3.UP)
	var forward := -global_transform.basis.z
	#if(flying):
		#forward.y = 0
	velocity = forward * speed
	if (!flying):
		gravity_velocity -= gravity
	velocity.y += gravity_velocity
	move_and_slide(velocity, Vector3(0,1,0))
	if is_on_floor():
		gravity_velocity = 0


func _on_Area_body_entered(body):
	var enemy := body as Enemy
	if enemy and enemy != self:
		enemies_in_explode_range.append(enemy)


func _on_ExplodeArea_body_exited(body):
	var enemy := body as Enemy
	if enemy:
		enemies_in_explode_range.erase(enemy)

func playRandomHitSound():
	var random_int = rng.randi_range(1, 4)               # pick a valid random number
	var snd = get_node("HitSound"+str(random_int))  # select a sound
	snd.play()
	#yield(get_tree().create_timer(0.3), "timeout")
	#snd.stop()

func playRandomDeathSound():
	var random_int = rng.randi_range(1, 2)               # pick a valid random number
	var snd = get_node("DeathSound"+str(random_int))  # select a sound
	snd.play()
	#yield(get_tree().create_timer(0.3), "timeout")
	#snd.stop()
	
