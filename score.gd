extends Node2D

var names
var scores
var cardscores
var cardcounts
var puddings
var round
var playerscene
var players
const gap = 108
const left = 4
var wasabi
var wasabion
var wasabioff
var maki1
var maki2
var rounds

signal game_over
signal reset_scores
signal flash1
signal flash2

# Called when the node enters the scene tree for the first time.
func _ready():
	round = 1
	rounds = Settings.settings["Rounds"]
	cardscores = []
	cardcounts = []
	maki1 = 0
	maki2 = 0
	$Round.text = "1/" + str(rounds)
	playerscene = preload("res://player.tscn")
	wasabion = preload("res://Art/WasabiOn.png")
	wasabioff = preload("res://Art/WasabiOff.png")
	players = [playerscene.instantiate()]
	players[0].position.x = left
	flash1.connect(players[0].get_node("Maki")._flash_first)
	flash2.connect(players[0].get_node("Maki")._flash_second)
	players[0].name_changed.connect(_handle_names_updated)
	$Players/PlayersArea/PlayersArea2.add_child(players[0])
	$Players/PlayersArea.custom_minimum_size.x = gap
	wasabi = false
	for counter in [players[0].get_node("Maki"), players[0].get_node("TempuraCounter"), players[0].get_node("SashimiCounter"), players[0].get_node("DumplingCounter"), players[0].get_node("SquidCounter"), players[0].get_node("SalmonCounter"), players[0].get_node("EggCounter"), players[0].get_node("PuddingCounter")]:
		counter.score_update.connect(_handle_score_update)
	players[0].split = Settings.settings["Split"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_add_pressed():
	var new_player = playerscene.instantiate()
	new_player.position.x = left + gap*len(players)
	"""for button in [$Add, $Home, $Confirm, $Wasabi]:
		button.position.x += gap"""
	flash1.connect(new_player.get_node("Maki")._flash_first)
	flash2.connect(new_player.get_node("Maki")._flash_second)
	new_player.name_changed.connect(_handle_names_updated)
	$Players/PlayersArea/PlayersArea2.add_child(new_player)
	$Players/PlayersArea.custom_minimum_size.x += gap
	for counter in [new_player.get_node("Maki"), new_player.get_node("TempuraCounter"), new_player.get_node("SashimiCounter"), new_player.get_node("DumplingCounter"), new_player.get_node("SquidCounter"), new_player.get_node("SalmonCounter"), new_player.get_node("EggCounter"), new_player.get_node("PuddingCounter")]:
		counter.score_update.connect(_handle_score_update)
	new_player.split = Settings.settings["Split"]
	players.append(new_player)


func _on_confirm_pressed():
	"""var maki1 = 0
	var maki2 = 0
	for player in players:
		if player.get_node("Maki").first:
			maki1 += 1
		elif player.get_node("Maki").second:
			maki2 += 1"""
	if maki1 == 0:
		emit_signal("flash1")
		if maki2 == 0:
			emit_signal("flash2")
	elif maki2 == 0 and maki1 <= 1 and len(players) > 1:
		emit_signal("flash2")
	elif maki1 >= 2 and maki2 >= 1 and Settings.settings["Second"] == false:
		emit_signal("flash2")
	else:
		$Players.scroll_horizontal = 0
		$Add.visible = false
		$Delete.visible = false
		if round == 1:
			$Favourite.position.y -= 64*2
			$Wasabi.position.y -= 64*2
		var player
		for i in range(len(players)):
			player = players[i]
			player.totalscores.append(player.score)
			player.puddings += player.get_node("PuddingCounter").num
			if i >= len(cardscores):
				cardscores.append([0,0,0,0,0,0,0,0])
				cardcounts.append([0,0,0,0,0,0,0,0])
			if player.get_node("Maki").first:
				if Settings.settings["Split"]:
					cardscores[i][0] += 6 / maki1
				else:
					cardscores[i][0] += 6
			elif player.get_node("Maki").second:
				if Settings.settings["Split"]:
					cardscores[i][0] += 3 / maki2
				else:
					cardscores[i][0] += 3
			cardscores[i][1] += player.get_node("TempuraCounter").num / 2 * 5
			cardscores[i][2] += player.get_node("SashimiCounter").num / 3 * 10
			if player.get_node("DumplingCounter").num >= 5:
				cardscores[i][3] += 15
			else:
				cardscores[i][3] += [0,1,3,6,10,15][player.get_node("DumplingCounter").num]
			cardscores[i][4] += player.get_node("SquidCounter").num * 3
			cardscores[i][5] += player.get_node("SalmonCounter").num * 2
			cardscores[i][6] += player.get_node("EggCounter").num
			var e = 0
			for counter in ["Tempura", "Sashimi", "Dumpling", "Squid", "Salmon", "Egg", "Pudding"]:
				cardcounts[i][e] += player.get_node(counter+"Counter").num
				e += 1
			player.get_node("Score").text = "0"
			player.score = 0
		maki1 = 0
		maki2 = 0
		if round >= rounds:
			names = []
			scores = []
			var maxpud = 0
			var maxpudi = []
			var nummaxpud = 0
			var minpud = 1000
			var minpudi = []
			var numminpud = 0
			for i in range(len(players)):
				var name = players[i].get_node("Name").text
				if name == "":
					names.append("Player " + str(i+1))
				else:
					names.append(name)
				scores.append(players[i].totalscores + [0])
				if players[i].puddings >= maxpud:
					if players[i].puddings > maxpud:
						maxpud = players[i].puddings
						maxpudi = [i]
						nummaxpud = 1
					else:
						maxpudi.append(i)
						nummaxpud += 1
				if players[i].puddings <= minpud:
					if players[i].puddings < minpud:
						minpud = players[i].puddings
						minpudi = [i]
						numminpud = 1
					else:
						minpudi.append(i)
						numminpud += 1
			for highest in maxpudi:
				if Settings.settings["Split"]:
					scores[highest][-1] += 6 / nummaxpud
					cardscores[highest][7] += 6 / nummaxpud
				else:
					scores[highest][-1] += 6
					cardscores[highest][7] += 6
			for lowest in minpudi:
				if Settings.settings["Split"]:
					scores[lowest][-1] -= 6 / numminpud
					cardscores[lowest][7] -= 6 / numminpud
				else:
					scores[lowest][-1] -= 6
					cardscores[lowest][7] -= 6
			emit_signal("game_over")
		else:
			round += 1
			$Round.text = str(round) + "/" + str(rounds)
			emit_signal("reset_scores")
	


func _on_wasabi_pressed():
	if wasabi:
		$Wasabi.texture_normal = wasabioff
	else:
		$Wasabi.texture_normal = wasabion
	wasabi = not wasabi

func _wasabi_off():
	$Wasabi.texture_normal = wasabioff
	wasabi = false
	
func _handle_score_update():
	for player in players:
		player._handle_score_update()

func _handle_names_updated():
	var snames = []
	for player in players:
		snames.append(player.get_node("Name").text)
	snames.sort()
	var st = snames[0]
	for s in snames.slice(1):
		st += ',' + s
	if st in Settings.matchups.keys():
		$Favourite.disabled = true
	else:
		$Favourite.disabled = false

func _on_delete_pressed():
	$Players/PlayersArea/PlayersArea2.remove_child(players[-1])
	$Players/PlayersArea.custom_minimum_size.x -= gap
	players.remove_at(len(players)-1)
