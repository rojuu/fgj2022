extends Control

var main

func _ready():
	$Control/VBoxContainer/Button.text = "Start"

func back_to_menu():
	$Control.visible = true
	$Control/VBoxContainer/Button.text = "Restart"

func _draw():
	var vp_size := get_viewport().size
	var vp_half_size := Vector2(vp_size.x/2, vp_size.y/2)

	# draw crosshair
	var crosshair_size = 4
	var crosshair_width = 0.5
	var crosshair_color = Color.green
	draw_line(Vector2(-crosshair_size-1, 0)+vp_half_size, Vector2(crosshair_size, 0)+vp_half_size, crosshair_color, crosshair_width)
	draw_line(Vector2(0, -crosshair_size-1)+vp_half_size, Vector2(0, crosshair_size)+vp_half_size, crosshair_color, crosshair_width)


func _on_Button_pressed():
	$Control.visible = false
	main.restart()
