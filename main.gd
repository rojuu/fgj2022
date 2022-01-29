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


func _on_Player_died():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$UI.back_to_menu()
	remove_child(td_main)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		

