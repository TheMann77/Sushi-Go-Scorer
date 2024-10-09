extends Node2D

var names = ["Alex", "Imi"]
var scores = [[5,6,7,6], [3,7,8,-6]]
var rows = ["Round 1", "Round 2", "Round 3", "Puddings"]
var tablename = ""
const padding = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_vals(newnames, newscores, newrows, newtablename, header_width):
	names = newnames
	scores = newscores
	rows = newrows
	tablename = newtablename
	const table_column = preload("res://table_column.tscn")
	const table_header = preload("res://table_header.tscn")
	var newheader = table_header.instantiate() 
	newheader.set_vals(rows, tablename)
	newheader.set_width(header_width)
	newheader.position.x = padding
	add_child(newheader)
	for i in range(len(names)):
		var cell_width = (480 - header_width - padding*(len(names)+2)) / len(names)
		var newplayer = table_column.instantiate()
		newplayer.set_vals(scores[i], names[i])
		newplayer.set_width(cell_width)
		newplayer.position.x = header_width + (cell_width+padding)*i+padding*2
		add_child(newplayer)
