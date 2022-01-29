extends Node

func _ready():
	# Hide the mouse and lock to screen
	# to show the mouse again do Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

