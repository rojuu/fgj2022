extends KinematicBody

class_name Enemy

export(float) var health = 6
export(float) var speed = 10
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

func _ready():
	rng.randomize()
	hitvfx.emitting = false
	deathvfx.emitting = false
	explodevfx.emitting = false


func random_element_from_array(arr):
	var idx = rng.randi_range(0, len(arr)-1)
	return arr[idx]


func drop_random_weapon():
	if len(drop_weapons) == 0:
		return
	var weapon_scene = random_element_from_array(drop_weapons)
	var weapon := weapon_scene.instance() as RigidBody
	get_tree().root.add_child(weapon)
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
	$AudioStreamPlayer3D.play()
	hitvfx.restart()
	yield(get_tree().create_timer(0.3), "timeout")
	$AudioStreamPlayer3D.stop()
	sprite.modulate = Color.white
	if dying:
		if rng.randf() < weapon_drop_chance:
			drop_random_weapon()
		queue_free()


func _process(delta):
	$DebugViewport/Control/NumberOfEnemiesInExplodeRange.text = String(len(enemies_in_explode_range))


func _physics_process(delta):
	if dying:
		return

	look_at(player.translation, Vector3.UP)
	var forward := -global_transform.basis.z
	if(flying):
		forward.y = 0
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
