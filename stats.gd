extends Node2D

const main_stats_path = Settings.version+"://stats.save"
const main_players_path = Settings.version+"://players.save"
var cell2
var cell3
var header2
var header3
var names
var stats
var player_stats
var extra_children
var stats_paths
var players_paths
var matchup_index
var titles
var matchups_list

# Called when the node enters the scene tree for the first time.
func _ready():
	print(Settings.matchups)
	matchups_list = Settings.matchups.keys()
	$C1/C2/C3/Delete.visible = false
	$Popup.visible = false
	$TooltipPopup.visible = false
	if len(matchups_list) == 0:
		$LeftButton.visible = false
		$RightButton.visible = false
		$Hint.visible = true
	else:
		$LeftButton.visible = true
		$RightButton.visible = true
		$Hint.visible = false
		stats_paths = [main_stats_path]
		players_paths = [main_players_path]
		titles = ["All-time stats"]
		for matchup in matchups_list:
			var i = Settings.matchups[matchup]
			stats_paths.append(Settings.version+"://stats"+str(i)+".save")
			players_paths.append(Settings.version+"://players"+str(i)+".save")
			titles.append(matchup)
	matchup_index = 0
	show_stats(main_stats_path, main_players_path)


func show_stats(stats_path, players_path):
	extra_children = []
	$C1.get_v_scroll_bar().modulate = Color(0,0,0,0)
	if FileAccess.file_exists(stats_path) and FileAccess.file_exists(players_path):
		cell2 = preload("res://stats_cell2.tscn")
		cell3 = preload("res://stats_cell3.tscn")
		header2 = preload("res://stats_header2.tscn")
		header3 = preload("res://stats_header3.tscn")
		var stats_file = FileAccess.open(stats_path, FileAccess.READ)
		var json_string = stats_file.get_line()
		var json = JSON.new()
		json.parse(json_string)
		stats = json.get_data()
		stats_file.close()
		var players_file = FileAccess.open(players_path, FileAccess.READ)
		json_string = players_file.get_line()
		json = JSON.new()
		json.parse(json_string)
		player_stats = json.get_data()
		players_file.close()
		names = player_stats.keys()
		
		for n in names:
			overwrite(player_stats[n]["Points per game"], stats["Most percentage"]["Points"], n)
			overwrite(player_stats[n]["Points per game"], stats["Least percentage"]["Points"], n, true)
			for place in ["Win", "2nd place", "3rd place", "Last place"]:
				overwrite(player_stats[n][place+" percentage"], stats["Most percentage"][place+"s"], n)
				overwrite(player_stats[n][place+" percentage"], stats["Least percentage"][place+"s"], n, true)
			overwrite(player_stats[n]["Win streak"], stats["Most"]["Current win streak"], n)
			overwrite(player_stats[n]["Games"], stats["Most"]["Games without a win"], n, false, true)
			for field in ["Round 1", "Round 2", "Round 3", "Puddings", "Maki", "Tempura", "Sashimi", "Dumplings", "Squid", "Salmon", "Egg"]:
				overwrite(player_stats[n]["Points by percentage"][field], stats["Points by percentage"][field], n)
		
		#$C1.get_v_scroll_bar().set("modulate", Color(0,0,0,0))
		$C1/C2/C3/TotalGames/Val.text = str(stats["Total"]["Games"])
		$C1/C2/C3/TotalPoints/Val.text = str(stats["Total"]["Points"])
		$C1/C2/C3/MostWins/Name.text = join(stats["Most number"]["Wins"][0], ', ')
		$C1/C2/C3/MostWins/Val.text = str(stats["Most number"]["Wins"][1])
		$C1/C2/C3/WinPercent/Name.text = join(stats["Most percentage"]["Wins"][0], ', ')
		$C1/C2/C3/WinPercent/Val.text = str(stats["Most percentage"]["Wins"][1])+"%"
		$C1/C2/C3/MostPoints/Name.text = join(stats["Most number"]["Points"][0], ', ')
		$C1/C2/C3/MostPoints/Val.text = str(stats["Most number"]["Points"][1])
		$C1/C2/C3/PointsPerGame/Name.text = join(stats["Most percentage"]["Points"][0], ', ')
		$C1/C2/C3/PointsPerGame/Val.text = str(stats["Most percentage"]["Points"][1])
		
		var ypos =  158*3 - 4
		var most_vals = [[], []]
		for field in ["2nd places", "3rd places", "Last places"]:
			most_vals[0].append(stats["Most number"][field])
			most_vals[1].append(stats["Most percentage"][field])
		ypos = create_table("Most", ["Number", "%"], ["2nd places", "3rd places", "Last places"], most_vals, ypos, true)

		var least_vals = []
		for field in ["Points", "Wins", "2nd places", "3rd places", "Last places"]:
			least_vals.append(stats["Least percentage"][field])
		ypos = create_table("Least", [""], ["Points per game", "Win %", "2nd place %", "3rd place %", "Last place %"], [least_vals], ypos, true, true)
		
		most_vals = []
		for field in ["Consecutive wins", "Consecutive games without winning", "Consecutive last places"]:
			most_vals.append(stats["Most"][field])
		ypos = create_table("Most consecutive", [""], ["Wins", "Games without winning", "Last places"], [most_vals], ypos)
		
		most_vals = []
		for field in ["Current win streak", "Games without a win"]:
			most_vals.append(stats["Most"][field])
		ypos = create_table("Miscellaneous", [""], ["Longest current win streak", "Most games without a win"], [most_vals], ypos)
		
		most_vals = [[], []]
		for field in [" game score", " round score"]:
			most_vals[0].append(stats["Records"]["Highest"+field])
			most_vals[1].append(stats["Records"]["Lowest"+field])
		ypos = create_table("Records", ["Highest", "Lowest"], ["Game score", "Round score"], most_vals, ypos)
		
		most_vals = []
		for field in ["Biggest win (1st to 2nd)", "Biggest win (1st to average)", "Biggest win (1st to last)", "Biggest loss (last to 2nd last)", "Biggest loss (last to average)", "Biggest loss (last to 1st)"]:
			most_vals.append(stats["Records"][field])
		ypos = create_table("Biggest wins and losses", [""], ["Biggest win (1st to 2nd)", "Biggest win (1st to average)", "Biggest win (1st to last)", "Biggest loss (last to 2nd last)", "Biggest loss (last to average)", "Biggest loss (last to 1st)"], [most_vals], ypos)
		
		most_vals = [[], []]
		for field in ["Round 1", "Round 2", "Round 3", "Puddings", "Maki", "Tempura", "Sashimi", "Dumplings", "Squid", "Salmon", "Egg"]:
			most_vals[0].append(stats["Points by number"][field])
			most_vals[1].append(stats["Points by percentage"][field])
		ypos = create_table("Most points by", ["Number", "%"], ["Round 1", "Round 2", "Round 3", "Puddings", "Maki", "Tempura", "Sashimi", "Dumplings", "Squid", "Salmon", "Egg"], most_vals, ypos, true)
		
		if stats_path != main_stats_path:
			if Settings.version == "res":
				$C1/C2/C3/Delete.position.y = 100
			else:
				$C1/C2/C3/Delete.position.y = ypos + 16
			ypos += 16 + $C1/C2/C3/Delete/DeleteButton.size.y*$C1/C2/C3/Delete/DeleteButton.scale.y
		$C1/C2.custom_minimum_size.y = ypos + 16
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func join(arr, str):
	if len(arr) == 0:
		return "-"
	var s = ""
	for i in range(len(arr)-1):
		s += arr[i] + str
	s += arr[len(arr)-1]
	return s

func create_table(name, col_names, row_names, vals, ypos, per=false, ex=false):
	var table = Area2D.new()
	var header
	if len(col_names) == 1:
		header = header2.instantiate()
		header.get_node("Val").text = col_names[0]
	else:
		header = header3.instantiate()
		header.get_node("Val1").text = col_names[0]
		header.get_node("Val2").text = col_names[1]
	header.get_node("Field").text = name + ":"
	table.add_child(header)
	var valtext
	for i in range(len(row_names)):
		var cell
		if len(col_names) == 1:
			cell = cell2.instantiate()
			if per and not (ex and i==0):
				valtext = [join(vals[0][i][0], ', '), ' - ' + str(vals[0][i][1])+"%"]
			else:
				valtext = [join(vals[0][i][0], ', '), ' - ' + str(vals[0][i][1])]
			cell.get_node("Val").text = shorten(valtext, 28)
		else:
			cell = cell3.instantiate()
			cell.get_node("Val1").text = shorten([join(vals[0][i][0], ', '), ' - ' + str(vals[0][i][1])],19)
			if per:
				cell.get_node("Val2").text = shorten([join(vals[1][i][0], ', '), ' - ' + str(vals[1][i][1])+"%"],19)
			else:
				cell.get_node("Val2").text = shorten([join(vals[1][i][0], ', '), ' - ' + str(vals[1][i][1])],19)
		cell.get_node("Field").text = row_names[i] #+ ":"
		cell.position.y = 32 * (i+1) - 4
		table.add_child(cell)
	table.position.y = ypos
	$C1/C2/C3.add_child(table)
	extra_children.append(table)
	return ypos + 32*(len(row_names)+1) - 4
	
func overwrite(nfield, statsfield, n, rev=false, wowin=false):
	if (not wowin) or player_stats[n]["Wins"] == 0:
		if (nfield > statsfield[1] and not rev) or (nfield < statsfield[1] and rev):
			statsfield[0] = [n]
			statsfield[1] = nfield
		elif nfield == statsfield[1]:
			if n not in statsfield[0]:
				statsfield[0].append(n)

func shorten(s, l):
	if len(s[0] + s[1]) <= l:
		return s[0] + s[1]
	else:
		return s[0].substr(0,l-len(s[1])-1) + ".." + s[1]


func _on_right_button_pressed():
	for ch in extra_children:
		$C1/C2/C3.remove_child(ch)
	extra_children = []
	matchup_index = (matchup_index + 1) % len(players_paths)
	show_stats(stats_paths[matchup_index], players_paths[matchup_index])
	$Title.text = titles[matchup_index]
	if matchup_index == 0:
		$C1/C2/C3/Delete.visible = false
	else:
		$C1/C2/C3/Delete.visible = true

func _on_left_button_pressed():
	for ch in extra_children:
		$C1/C2/C3.remove_child(ch)
	extra_children = []
	matchup_index = (matchup_index - 1) % len(players_paths)
	show_stats(stats_paths[matchup_index], players_paths[matchup_index])
	$Title.text = titles[matchup_index]
	if matchup_index == 0:
		$C1/C2/C3/Delete.visible = false
	else:
		$C1/C2/C3/Delete.visible = true

func _on_delete_button_pressed():
	$Popup.visible = true

func _on_cancel_button_pressed():
	$Popup.visible = false

func _on_confirm_button_pressed():
	var ma = Settings.matchups
	ma.erase(matchups_list[matchup_index-1])
	Settings.matchups = ma
	var matchups_file = FileAccess.open(Settings.matchups_path, FileAccess.WRITE)
	matchups_file.store_line(JSON.stringify(Settings.matchups))
	
	matchups_list.remove_at(matchup_index-1)
	DirAccess.remove_absolute(stats_paths[matchup_index])
	DirAccess.remove_absolute(players_paths[matchup_index])
	matchup_index = matchup_index % (len(matchups_list)+1)
	if matchup_index == 0:
		$C1/C2/C3/Delete.visible = false
	$Popup.visible = false
	$TooltipPopup.visible = false
	if len(matchups_list) == 0:
		$LeftButton.visible = false
		$RightButton.visible = false
		$Hint.visible = true
	else:
		$LeftButton.visible = true
		$RightButton.visible = true
		$Hint.visible = false
		stats_paths.remove_at(matchup_index)
		players_paths.remove_at(matchup_index)
		titles.remove_at(matchup_index)
	for ch in extra_children:
		$C1/C2/C3.remove_child(ch)
	extra_children = []
	$Title.text = titles[matchup_index]
	show_stats(stats_paths[matchup_index], players_paths[matchup_index])


func _on_hint_pressed():
	$TooltipPopup.visible = true


func _on_close_button_pressed():
	$TooltipPopup.visible = false
