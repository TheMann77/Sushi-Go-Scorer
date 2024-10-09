extends Node
var num
signal score_update
signal wasabi_off
var is_nigiri

# Called when the node enters the scene tree for the first time.
func _ready():
	num = 0
	$Number.text = "0"
	$DownButton.set_deferred("disabled", true)
	is_nigiri = false
	get_parent().get_parent().get_parent().get_parent().get_parent().reset_scores.connect(_reset_scores)
	wasabi_off.connect(get_parent().get_parent().get_parent().get_parent().get_parent()._wasabi_off)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_up_button_pressed():
	if is_nigiri and get_parent().get_parent().get_parent().get_parent().get_parent().wasabi:
		num += 3
		emit_signal("wasabi_off")
	else:
		num += 1
	$DownButton.set_deferred("disabled", false)
	$Number.text = str(num)
	emit_signal("score_update")


func _on_down_button_pressed():
	if num > 0:
		if is_nigiri and get_parent().get_parent().get_parent().get_parent().get_parent().wasabi:
			if num >= 3:
				num -= 3
				emit_signal("wasabi_off")
		else:
			num -= 1
		if num == 0:
			$DownButton.set_deferred("disabled", true)
		$Number.text = str(num)
	emit_signal("score_update")

func _reset_scores():
	$DownButton.set_deferred("disabled", true)
	$Number.text = "0"
	num = 0
