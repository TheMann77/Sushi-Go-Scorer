extends Node

var first
var second
var goldbutton
var silverbutton
var emptygold
var emptysilver
var flashing1
var flashing2

signal score_update

# Called when the node enters the scene tree for the first time.
func _ready():
	first = false
	second = false
	flashing1 = false
	flashing2 = false
	goldbutton = preload("res://Art/GoldRect.png")
	silverbutton = preload("res://Art/SilverRect.png")
	emptygold = preload("res://Art/MakiBox1.png")
	emptysilver = preload("res://Art/MakiBox2.png")
	get_parent().get_parent().get_parent().get_parent().get_parent().reset_scores.connect(_reset_scores)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if flashing1:
		var olda = $FirstRed.modulate.a
		$FirstRed.set("modulate", Color(1,1,1,olda-.02))
		if olda-.02 <= 0:
			flashing1 = false
	if flashing2:
		var olda = $SecondRed.modulate.a
		$SecondRed.set("modulate", Color(1,1,1,olda-.02))
		if olda-.02 <= 0:
			flashing2 = false


func _on_1_st_pressed():
	if first:
		$First.texture_normal = emptygold
		get_parent().get_parent().get_parent().get_parent().get_parent().maki1 -= 1
	else:
		$First.texture_normal = goldbutton
		$Second.texture_normal = emptysilver
		if second:
			get_parent().get_parent().get_parent().get_parent().get_parent().maki2 -= 1
		second = false
		get_parent().get_parent().get_parent().get_parent().get_parent().maki1 += 1
	first = not first
	emit_signal("score_update")


func _on_2_nd_pressed():
	if second:
		$Second.texture_normal = emptysilver
		get_parent().get_parent().get_parent().get_parent().get_parent().maki2 -= 1
	else:
		$Second.texture_normal = silverbutton
		$First.texture_normal = emptygold
		if first:
			get_parent().get_parent().get_parent().get_parent().get_parent().maki1 -= 1
		first = false
		get_parent().get_parent().get_parent().get_parent().get_parent().maki2 += 1
	second = not second
	emit_signal("score_update")

func _reset_scores():
	first = false
	second = false
	$First.texture_normal = emptygold
	$Second.texture_normal = emptysilver

func _flash_first():
	flashing1 = true
	$FirstRed.set("modulate", Color(1,1,1,1))

func _flash_second():
	flashing2 = true
	$SecondRed.set("modulate", Color(1,1,1,1))
