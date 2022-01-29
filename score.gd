extends Label

var score
var player

func _ready():
	score = 0
	player =  get_tree().get_nodes_in_group("Player")[0]
	#score_loop()

#legacy shiiiiiiiiiiit
#func score_loop():
#	while(true):
#		yield(get_tree().create_timer(1.0), "timeout")
#		score += 1
#		text = str(score)

func _process(delta):
	text = str(int(player.alive_time))
