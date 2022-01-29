extends Label

var score

func _ready():
	score = 0
	score_loop()

func score_loop():
	while(true):
		yield(get_tree().create_timer(1.0), "timeout")
		score += 1
		text = str(score)
