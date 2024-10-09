extends Area2D

var score
var totalscores
var puddings

var split

signal name_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	totalscores = []
	puddings = 0
	split = true
	$SquidCounter.is_nigiri = true
	$SalmonCounter.is_nigiri = true
	$EggCounter.is_nigiri = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _handle_score_update():
	if $Maki.first:
		if split:
			score = 6 / get_parent().get_parent().get_parent().get_parent().maki1
		else:
			score = 6
	elif $Maki.second:
		if split:
			score = 3 / get_parent().get_parent().get_parent().get_parent().maki2
		else:
			score = 3
	else:
		score = 0
	score += $TempuraCounter.num / 2 * 5
	score += $SashimiCounter.num / 3 * 10
	if $DumplingCounter.num >= 5:
		score += 15
	else:
		score += [0,1,3,6,10,15][$DumplingCounter.num]
	score += $SquidCounter.num * 3
	score += $SalmonCounter.num * 2
	score += $EggCounter.num
	$Score.text = str(score)

func _on_name_text_changed(new_text):
	emit_signal("name_changed")
