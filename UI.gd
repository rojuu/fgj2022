extends Control

var main
var highscore: float
onready var ggsound = get_node("ggsound")

func update_highscore_ui():
	$Control/VBoxContainer/Higscore.text = "Highscore: %.3f" % highscore

func _ready():
	update_highscore_ui()
	$Control/VBoxContainer/Button.text = "Start"


func back_to_menu(alive_time, highscore_):
	highscore = highscore_
	update_highscore_ui()
	$Control/VBoxContainer/Label.text = "You survived for: %.3f seconds\n" % alive_time
	$Control.visible = true
	$Control/VBoxContainer/Button.text = "Restart"
	ggsound.play()
	yield(get_tree().create_timer(5), "timeout")
	ggsound.stop()


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
