extends KinematicBody

var speed = 10
var velocity = Vector3.ZERO



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_tree().root.find_node("Player")
	print(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#look_at()
	pass
