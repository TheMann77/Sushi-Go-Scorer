extends Node2D

var names
var scores
var cardscores
var players = []
const padding = 10
var totalscores
var maxscore
var minscore
var scores123
var index123
const k = 5
const short_time = 0.05
const long_time = .5
var time_gone
var num
var step_length
var start
var end
var statsdone
var raised
const screen_height = 900
const statsborder = screen_height - 3*padding - 14*25 - 5
var P1
var P2
var P3
const main_stats_path = Settings.version+"://stats.save"
const main_players_path = Settings.version+"://players.save"
const matchups_path = Settings.version+"://matchups.save"
var records
var recordsdone
var numrecordsdone = 0
var eachrecordsdone = []
var favourite

# Called when the node enters the scene tree for the first time.
func _ready():
	names = get_parent().names
	scores = get_parent().scores
	cardscores = get_parent().cardscores
	favourite = get_parent().favourite
	start = false
	end = false
	statsdone = false
	recordsdone = false
	raised = false
	for i in range(len(names)):
		eachrecordsdone.append(false)
	records = []
	totalscores = []
	scores123 = [0,0,0]
	minscore = 100000
	index123 = [[], [], []]
	const player_result_scene = preload("res://player_result.tscn")
	P1 = preload("res://Art/1st.png")
	P2 = preload("res://Art/2nd.png")
	P3 = preload("res://Art/3rd.png")
	var playersize = player_result_scene.instantiate().get_node("Background").size
	var nplayersize = (480 - padding*(1+len(names))) / len(names)
	var playerscale = nplayersize / playersize.x
	var new_player
	for i in range(len(names)):
		new_player = player_result_scene.instantiate()
		new_player.scale.x = playerscale
		new_player.scale.y = playerscale
		new_player.position.x = padding + i * (nplayersize + padding)
		new_player.position.y = screen_height - padding - (playersize.y * playerscale) - 37*playerscale
		new_player.get_node("Background").size.y = screen_height / playerscale
		new_player.get_node("Name").text = names[i]
		add_child(new_player)
		players.append(new_player)
		
		var score = 0
		for roundscore in scores[i]:
			score += roundscore
		totalscores.append(score)
		if score < minscore:
			minscore = score
		if score >= scores123[0]:
			if score > scores123[0]:
				index123 = [[i]] + index123.slice(0,2)
				scores123 = [score] + scores123.slice(0,2)
			else:
				index123[0].append(i)
		elif score >= scores123[1]:
			if score > scores123[1]:
				index123 = [index123[0]] + [[i]] + [index123[1]]
				scores123 = [scores123[0]] + [score] + [scores123[1]]
			else:
				index123[1].append(i)
		elif score >= scores123[2]:
			if score > scores123[2]:
				index123 = index123.slice(0,2) + [[i]]
				scores123 = scores123.slice(0,2) + [score]
			else:
				index123[2].append(i)
	if len(index123[0]) == 2:
		index123[2] = index123[1]
		scores123[2] = scores123[1]
		index123[1] = []
		scores123[1] = null
	elif len(index123[0]) == 3:
		index123[1] = []
		index123[2] = []
		scores123[1] = null
		scores123[2] = null
	elif len(index123[1]) == 2:
		index123[2] = []
		scores123[2] = null
	maxscore = scores123[0]
	time_gone = 0.0
	num = 0
	#step_length = (screen_height - 20 - 2*padding - playersize.y * playerscale) / maxscore
	step_length = (new_player.position.y - 56 - 20) / (maxscore)
	$Tables/RoundTable.set_vals(names, scores, ["Round 1", "Round 2", "Round 3", "Puddings"], "", 80)
	$Tables/CardsTable.set_vals(names, cardscores, ["Maki", "Tempura", "Sashimi", "Dumplings", "Squid", "Salmon", "Egg", "Puddings"], "", 80)
	var totalscores2d = []
	for totalscore in totalscores:
		totalscores2d.append([totalscore])
	$Tables/TotalTable.set_vals(names, totalscores2d, ["Total"], "", 80)
	
	var stats_file
	var players_file
	var stats
	var player_stats
	var json_string
	
	var stats_paths
	var players_paths
	var snames = names
	snames.sort()
	var st = snames[0]
	for s in snames.slice(1):
		st += ',' + s
	if favourite:
		var i = 0
		while i in Settings.matchups.values():
			i += 1
		stats_paths = [main_stats_path, Settings.version+"://stats"+str(i)+".save"]
		players_paths = [main_players_path, Settings.version+"://players"+str(i)+".save"]
		Settings.matchups[st] = i
		var matchups_file = FileAccess.open(matchups_path, FileAccess.WRITE)
		matchups_file.store_line(JSON.stringify(Settings.matchups))
		
	elif st in Settings.matchups.keys():
		var i = Settings.matchups[st]
		stats_paths = [main_stats_path, Settings.version+"://stats"+str(i)+".save"]
		players_paths = [main_players_path, Settings.version+"://players"+str(i)+".save"]
	else:
		stats_paths = [main_stats_path]
		players_paths = [main_players_path]
	for b in range(len(stats_paths)):
		var stats_path = stats_paths[b]
		var players_path = players_paths[b]
		if FileAccess.file_exists(stats_path) and FileAccess.file_exists(players_path):
			stats_file = FileAccess.open(stats_path, FileAccess.READ)
			players_file = FileAccess.open(players_path, FileAccess.READ)
			
			json_string = stats_file.get_line()
			var json = JSON.new()
			json.parse(json_string)
			stats = json.get_data()
			
			json_string = players_file.get_line()
			json = JSON.new()
			json.parse(json_string)
			player_stats = json.get_data()
			
			stats_file.close()
			players_file.close()
		else:
			player_stats = {}
			stats = {
				"Total": {
					"Games": 0,
					"Points": 0
				},
				"Most number": {
					"Games": [[], 0],
					"Points": [[], 0],
					"Wins": [[], 0],
					"2nd places": [[], 0],
					"3rd places": [[], 0],
					"Last places": [[], 0]
				},
				"Most percentage": {
					"Points": [[], 0],
					"Wins": [[], 0],
					"2nd places": [[], 0],
					"3rd places": [[], 0],
					"Last places": [[], 0]
				},
				"Least percentage": {
					"Points": [[], 100.0],
					"Wins": [[], 100.0],
					"2nd places": [[], 100.0],
					"3rd places": [[], 100.0],
					"Last places": [[], 100.0]
				},
				"Most": {
					"Consecutive wins": [[], 0],
					"Current win streak": [[], 0],
					"Consecutive games without winning": [[], 0],
					"Games without a win": [[], 0],
					"Consecutive last places": [[], 0]
				},
				"Records": {
					"Highest game score": [[], 0],
					"Lowest game score": [[], 9999],
					"Highest round score": [[], 0],
					"Lowest round score": [[], 9999],
					"Biggest win (1st to 2nd)": [[], 0],
					"Biggest win (1st to average)": [[], 0],
					"Biggest win (1st to last)": [[], 0],
					"Biggest loss (last to 2nd last)": [[], 0],
					"Biggest loss (last to average)": [[], 0],
					"Biggest loss (last to 1st)": [[], 0]
				},
				"Points by number": {
					"Round 1": [[], 0],
					"Round 2": [[], 0],
					"Round 3": [[], 0],
					"Puddings": [[], 0],
					"Maki": [[], 0],
					"Tempura": [[], 0],
					"Sashimi": [[], 0],
					"Dumplings": [[], 0],
					"Squid": [[], 0],
					"Salmon": [[], 0],
					"Egg": [[], 0],
				},
				"Points by percentage": { ## Not done
					"Round 1": [[], 0],
					"Round 2": [[], 0],
					"Round 3": [[], 0],
					"Puddings": [[], 0],
					"Maki": [[], 0],
					"Tempura": [[], 0],
					"Sashimi": [[], 0],
					"Dumplings": [[], 0],
					"Squid": [[], 0],
					"Salmon": [[], 0],
					"Egg": [[], 0],
				}
			}
		var n
		stats["Total"]["Games"] += 1
		for i in range(len(names)):
			var record = []
			stats["Total"]["Points"] += totalscores[i]
			if names[i] != "Player " + str(i+1):
				if not player_stats.has(names[i]):
					n = {
						"Games": 0,
						"Points": 0,
						"Points per game": 0,
						"Wins": 0,
						"Win percentage": 0,
						"2nd places": 0,
						"2nd place percentage": 0,
						"3rd places": 0,
						"3rd place percentage": 0,
						"Last places": 0,
						"Last place percentage": 0,
						"Win streak": 0,
						"Most consecutive wins": 0,
						"Consecutive games without winning": 0,
						"Most consecutive games without winning": 0,
						"Consecutive last places": 0,
						"Most consecutive last places": 0,
						"Highest game score": 0,
						"Lowest game score": 9999,
						"Highest round score": 0,
						"Lowest round score": 9999,
						"Biggest win": {
							"1st to 2nd": 0,
							"1st to average": 0,
							"1st to last": 0,
						},
						"Biggest loss": {
							"last to 2nd last": 0,
							"last to average": 0,
							"last to 1st": 0,
						},
						"Points by": {
							"Round 1": 0,
							"Round 2": 0,
							"Round 3": 0,
							"Puddings": 0,
							"Maki": 0,
							"Tempura": 0,
							"Sashimi": 0,
							"Dumplings": 0,
							"Squid": 0,
							"Salmon": 0,
							"Egg": 0
						},
						"Points by percentage": {
							"Round 1": 0,
							"Round 2": 0,
							"Round 3": 0,
							"Puddings": 0,
							"Maki": 0,
							"Tempura": 0,
							"Sashimi": 0,
							"Dumplings": 0,
							"Squid": 0,
							"Salmon": 0,
							"Egg": 0
						}
					}
				else:
					n = player_stats[names[i]]
				
				n["Games"] += 1
				if overwrite(n["Games"], stats["Most number"]["Games"], i):
					pass#record.append("New most games played")
				n["Points"] += totalscores[i]
				if overwrite(n["Points"], stats["Most number"]["Points"], i):
					pass#record.append("New most points scored")
				n["Points per game"] = round(10.0 * float(n["Points"]) / float(n["Games"]))/10.0
				if totalscores[i] == scores123[0]:
					n["Wins"] += 1
					if overwrite(n["Wins"], stats["Most number"]["Wins"], i):
						pass#record.append("New most wins")
				elif totalscores[i] == scores123[1]:
					n["2nd places"] += 1
					if overwrite(n["2nd places"], stats["Most number"]["2nd places"], i):
						pass#record.append("New most 2nd places")
				elif totalscores[i] == scores123[2]:
					n["3rd places"] += 1
					if overwrite(n["3rd places"], stats["Most number"]["3rd places"], i):
						pass#record.append("New most 3rd places")
				if totalscores[i] == minscore:
					n["Last places"] += 1
					if overwrite(n["Last places"], stats["Most number"]["Last places"], i):
						pass#record.append("New most last places")
					n["Consecutive last places"] += 1
					if n["Consecutive last places"] > n["Most consecutive last places"]:
						n["Most consecutive last places"] += 1
						if overwrite(n["Consecutive last places"], stats["Most"]["Consecutive last places"], i):
							pass#record.append("New most consecutive last places")
					var lossave
					var loss2
					var spare_array = [] + totalscores
					if len(totalscores) > 1:
						lossave = round(10 * (sum(totalscores) - totalscores[i]) / (len(totalscores)-1)) / 10 - totalscores[i]
						spare_array.erase(minscore)
						loss2 = spare_array.min() - minscore
					else:
						lossave = 0
						loss2 = 0
					var bigloss = false
					if lossave > n["Biggest loss"]["last to average"]:
						n["Biggest loss"]["last to average"] = lossave
						if overwrite(n["Biggest loss"]["last to average"], stats["Records"]["Biggest loss (last to average)"], i):
							bigloss = true
					if maxscore - minscore > n["Biggest loss"]["last to 1st"]:
						n["Biggest loss"]["last to 1st"] = maxscore - minscore
						if overwrite(n["Biggest loss"]["last to 1st"], stats["Records"]["Biggest loss (last to 1st)"], i):
							bigloss = true
					if loss2 > n["Biggest loss"]["last to 2nd last"]:
						n["Biggest loss"]["last to 2nd last"] = loss2
						if overwrite(n["Biggest loss"]["last to 2nd last"], stats["Records"]["Biggest loss (last to 2nd last)"], i):
							bigloss = true
					if bigloss:
						record.append("New biggest loss")
				else:
					n["Consecutive last places"] = 0
				n["Win percentage"] = round(100.0 * float(n["Wins"]) / float(n["Games"]))
				n["2nd place percentage"] = round(100.0 * float(n["2nd places"]) / float(n["Games"]))
				n["3rd place percentage"] = round(100.0 * float(n["3rd places"]) / float(n["Games"]))
				n["Last place percentage"] = round(100.0 * float(n["Last places"]) / (n["Games"]))
				if totalscores[i] == maxscore:
					n["Win streak"] += 1
					if n["Win streak"] > n["Most consecutive wins"]:
						n["Most consecutive wins"]  += 1
						if overwrite(n["Most consecutive wins"], stats["Most"]["Consecutive wins"], i):
							pass#record.append("New most consecutive wins")
					n["Consecutive games without winning"] = 0
					var win2
					if scores123[1] == null:
						win2 = 0
					else:
						win2 = totalscores[i] - scores123[1]
					var winave
					if len(totalscores) > 1:
						winave = totalscores[i] - round(10 * (sum(totalscores) - totalscores[i]) / (len(totalscores)-1)) / 10
					else:
						winave = 0
					var bigwin = false
					if win2 > n["Biggest win"]["1st to 2nd"]:
						n["Biggest win"]["1st to 2nd"] = win2
						if overwrite(n["Biggest win"]["1st to 2nd"], stats["Records"]["Biggest win (1st to 2nd)"], i):
							bigwin = true
					if winave > n["Biggest win"]["1st to average"]:
						n["Biggest win"]["1st to average"] = winave
						if overwrite(n["Biggest win"]["1st to average"], stats["Records"]["Biggest win (1st to average)"], i):
							bigwin = true
					if maxscore - minscore > n["Biggest win"]["1st to last"]:
						n["Biggest win"]["1st to last"] = maxscore - minscore
						if overwrite(n["Biggest win"]["1st to last"], stats["Records"]["Biggest win (1st to last)"], i):
							bigwin = true
					if bigwin:
						record.append("New biggest win")
				else:
					n["Win streak"] = 0
					n["Consecutive games without winning"] += 1
					if n["Consecutive games without winning"] > n["Most consecutive games without winning"]:
						n["Most consecutive games without winning"] += 1
						if overwrite(n["Most consecutive games without winning"], stats["Most"]["Consecutive games without winning"], i):
							pass#record.append("New most consecutive games without winning")
				if totalscores[i] > n["Highest game score"]:
					n["Highest game score"] = totalscores[i]
					if overwrite(n["Highest game score"], stats["Records"]["Highest game score"], i) and totalscores[i] == maxscore:
						record.append("New highest score")
				if totalscores[i] < n["Lowest game score"]:
					n["Lowest game score"] = totalscores[i]
					if n["Lowest game score"] < stats["Records"]["Lowest game score"][1]:
						stats["Records"]["Lowest game score"] = [[names[i]], n["Lowest game score"]]
						if totalscores[i] == minscore:
							record.append("New lowest score")
					elif n["Lowest game score"] == stats["Records"]["Lowest game score"][1]:
						stats["Records"]["Lowest game score"][0].append(names[i])
						if totalscores[i] == minscore:
							record.append("New lowest score")
				if scores[i].slice(0,3).max() > n["Highest round score"]:
					n["Highest round score"] = scores[i].slice(0,3).max()
					if overwrite(n["Highest round score"], stats["Records"]["Highest round score"], i):
						if scores[i].slice(0,3).max() == maxmax(scores):
							record.append("New highest round score")
				if scores[i].slice(0,3).min() < n["Lowest round score"]:
					n["Lowest round score"] = scores[i].slice(0,3).min()
					if n["Lowest round score"] < stats["Records"]["Lowest round score"][1]:
						stats["Records"]["Lowest round score"] = [[names[i]], n["Lowest round score"]]
						if scores[i].slice(0,3).min() == minmin(scores):
							record.append("New lowest round score")
					elif n["Lowest round score"] == stats["Records"]["Lowest round score"][1]:
						stats["Records"]["Lowest round score"][0].append(names[i])
						if scores[i].slice(0,3).min() == minmin(scores):
							record.append("New lowest round score")
				for round in range(3):
					n["Points by"]["Round "+str(round+1)] += scores[i][round]
					overwrite(n["Points by"]["Round "+str(round+1)], stats["Points by number"]["Round "+str(round+1)], i)
					n["Points by percentage"]["Round "+str(round+1)] = round(100.0 * float(n["Points by"]["Round "+str(round+1)]) / float(n["Points"]))
				n["Points by"]["Puddings"] += scores[i][3]
				overwrite(n["Points by"]["Puddings"], stats["Points by number"]["Puddings"], i)
				n["Points by percentage"]["Puddings"] = round(100.0 * n["Points by"]["Puddings"] / n["Points"])
				var card_types = ["Maki", "Tempura", "Sashimi", "Dumplings", "Squid", "Salmon", "Egg"]
				for e in range(7):
					n["Points by"][card_types[e]] += cardscores[i][e]
					overwrite(n["Points by"][card_types[e]], stats["Points by number"][card_types[e]], i)
					n["Points by percentage"][card_types[e]] = round(100.0 * float(n["Points by"][card_types[e]]) / float(n["Points"]))
				player_stats[names[i]] = n
				if b == 0:
					records.append(record)
		stats_file = FileAccess.open(stats_path, FileAccess.WRITE)
		stats_file.store_line(JSON.stringify(stats))
		players_file = FileAccess.open(players_path, FileAccess.WRITE)
		players_file.store_line(JSON.stringify(player_stats))
		stats_file.close()
		players_file.close()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if start and not end:
		time_gone += delta
		var threshold = (long_time - short_time) * (float(num)/float(maxscore))**k + short_time
		if time_gone > threshold:
			num += 1
			if num > maxscore:
				end = true
				time_gone = 0
				$Tables/RoundTable.position.y += 0
				$Tables/CardsTable.position.y += padding + 25*4
				$Tables/MidRect.position.y += padding + 25*4 - 2
				$Tables/TotalTable.position.y += padding*2 + 25*12
				$Tables/MidRect2.position.y += padding*2 + 25*12
			time_gone -= threshold
			for i in range(len(players)):
				if totalscores[i] >= num:
					players[i].get_node("Score").text = str(num)
					if totalscores[i] == num:
						if num == scores123[0]:
							players[i].get_node("Score").set("theme_override_colors/font_color", Color(.988, .780, .227))
							players[i].get_node("Name").set("theme_override_colors/font_color", Color(.988, .780, .227))
							players[i].get_node("Pos").set("texture", P1)
							players[i].get_node("Background").modulate = Color(.988, .780, .227)
						elif num == scores123[1]:
							players[i].get_node("Score").set("theme_override_colors/font_color", Color(.753, .753, .753))
							players[i].get_node("Name").set("theme_override_colors/font_color", Color(.753, .753, .753))
							players[i].get_node("Pos").set("texture", P2)
							players[i].get_node("Background").modulate = Color(.753, .753, .753)
						elif num == scores123[2]:
							players[i].get_node("Score").set("theme_override_colors/font_color", Color(.804, .498, .196))
							players[i].get_node("Name").set("theme_override_colors/font_color", Color(.804, .498, .196))	
							players[i].get_node("Pos").set("texture", P3)
							players[i].get_node("Background").modulate = Color(.804, .498, .196)
		for i in range(len(players)):
			if totalscores[i] > num:
				players[i].position.y -= step_length * delta / threshold
			if totalscores[i] < 0:
				players[i].get_node("Score").text = str(totalscores[i])
	elif end and not raised:
		var done = true
		for player in players:
			if player.position.y > 56:
				player.position.y -= float(player.position.y - 56 + 10) * delta
				done = false
			else:
				player.position.y = 56
		if done:
			raised = true
	elif raised and not recordsdone:
		time_gone += delta
		if time_gone > 1:
			for i in range(len(records)):
				if not eachrecordsdone[i]:
					if len(records[i]):
						players[i].get_node("Records").text += "\n" + records[i].pop_at(0)
						#players[i].get_node("ScrollContainer/VBoxContainer").custom_minimum_size.y += 15
						#players[i].get_node("ScrollContainer").set_v_scroll(players[i].get_node("ScrollContainer").get_v_scroll_bar().max_value)
					else:
						numrecordsdone += 1
						eachrecordsdone[i] = true
			if numrecordsdone >= len(records):
				recordsdone = true
			time_gone -= 1
	elif recordsdone and not statsdone:
		var v = $Tables.position.y - statsborder
		$Tables.position.y -= v*delta
		if $Tables.position.y < statsborder + 5:
			$Tables.position.y = statsborder + 5
			statsdone = true

func _on_timer_timeout():
	start = true

func sum(arr):
	var s = 0
	for a in arr:
		s += a
	return s
	
func overwrite(nfield, statsfield, i):
	if nfield > statsfield[1]:
		statsfield[0] = [names[i]]
		statsfield[1] = nfield
		return true
	elif nfield == statsfield[1]:
		if names[i] not in statsfield[0]:
			statsfield[0].append(names[i])
			return true
	return false

func maxmax(arr):
	var a  = []
	for ar in arr:
		a.append(ar.slice(0,3).max())
	return a.max()
	
func minmin(arr):
	var a  = []
	for ar in arr:
		a.append(ar.slice(0,3).min())
	return a.min()
