extends Node

onready var td_main_scene: PackedScene = preload("res://3d_main.tscn")

var td_main: Node

func restart():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	td_main = td_main_scene.instance()
	add_child(td_main)
	
	td_main.find_node("Player").connect("died", self, "_on_Player_died")


func _ready():
	$UI.main = self


func _on_Player_died(alive_time):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$UI.back_to_menu(alive_time)
	if td_main:
		td_main.queue_free()
		td_main = null

		
onready var was_0_pressed = false
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	if Input.is_key_pressed(KEY_0) and !was_0_pressed:
		was_0_pressed = true
		_on_Player_died(get_tree().get_nodes_in_group("Player")[0].alive_time)
	if !Input.is_key_pressed(KEY_0):
		was_0_pressed = false

