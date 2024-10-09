extends Node2D

var currentpage = null
var scorepage
var homepage
var resultspage
var statspage
var settingspage
var names
var scores
var cardscores
var favourite

# Called when the node enters the scene tree for the first time.
func _ready():
	homepage = preload("res://home.tscn")
	scorepage = preload("res://score.tscn")
	resultspage = preload("res://results.tscn")
	statspage = preload("res://stats.tscn")
	settingspage = preload("res://settings.tscn")
	
	_home_page()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _home_page():
	if currentpage:
		currentpage.queue_free()
	currentpage = homepage.instantiate()
	currentpage.get_node("Play").pressed.connect(_start_game)
	currentpage.get_node("Stats").pressed.connect(_goto_stats)
	currentpage.get_node("Settings").pressed.connect(_goto_settings)
	add_child(currentpage)
	
func _restart_game():
	names = currentpage.names
	currentpage.queue_free()
	currentpage = scorepage.instantiate()
	currentpage.game_over.connect(_handle_game_over)
	currentpage.get_node("Home").pressed.connect(_home_page)
	add_child(currentpage)
	currentpage.players[0].get_node("Name").text = names[0]
	for i in range(1, len(names)):
		currentpage._on_add_pressed()
		currentpage.players[i].get_node("Name").text = names[i]

func _handle_game_over():
	names = currentpage.names
	scores = currentpage.scores
	cardscores = currentpage.cardscores
	favourite = currentpage.get_node("Favourite").button_pressed
	currentpage.queue_free()
	currentpage = resultspage.instantiate()
	"""currentpage.position.y = 100"""
	add_child(currentpage)
	currentpage.get_node("Home").pressed.connect(_home_page)
	currentpage.get_node("Restart").pressed.connect(_restart_game)

func _start_game():
	currentpage.queue_free()
	currentpage = scorepage.instantiate()
	currentpage.game_over.connect(_handle_game_over)
	currentpage.get_node("Home").pressed.connect(_home_page)
	add_child(currentpage)
	
func _goto_stats():
	currentpage.queue_free()
	currentpage = statspage.instantiate()
	currentpage.get_node("Home").pressed.connect(_home_page)
	add_child(currentpage)

func _goto_settings():
	currentpage.queue_free()
	currentpage = settingspage.instantiate()
	currentpage.get_node("Home").pressed.connect(_home_page)
	add_child(currentpage)
