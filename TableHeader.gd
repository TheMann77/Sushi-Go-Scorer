extends Node2D

var vals = [10,8,5,6]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_vals(newvals, newname):
	vals = newvals
	const cell = preload("res://cell.tscn")
	var cell_height = $Name.size.y
	for i in range(len(vals)):
		var newval = cell.instantiate()
		newval.text = str(vals[i])
		newval.position.y = cell_height*(i+1)
		newval.position.x = 0
		newval.set("theme_override_colors/font_color", Color(255,255,255))
		add_child(newval)
	$Name.text = newname

func set_width(width):
	for child in get_children():
		child.size.x = width
