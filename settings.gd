extends Node2D


var settings_path = Settings.version+"://settings.save"
var stats_path = Settings.version+"://stats.save"
var players_path = Settings.version+"://players.save"
var buttonon
var buttonoff
var split
var settings

# Called when the node enters the scene tree for the first time.
func _ready():
	settings = Settings.settings
	buttonon = preload("res://Art/SettingsButtonOn.png")
	buttonoff = preload("res://Art/SettingsButtonOff.png")
	$Rounds/Num.text = str(settings["Rounds"])
	for button in ["Split", "Second", "Expansion", "ExpansionStats"]:
		get_node(button).get_node(button+"Button").button_pressed = settings[button]
	$Confirm.visible = false
	$Popup.visible = false
	$TooltipPopup.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_split_button_toggled(button_pressed):
	settings["Split"] = button_pressed
	_on_confirm_button_pressed()

func _on_second_button_toggled(button_pressed):
	settings["Second"] = button_pressed
	_on_confirm_button_pressed()

func _on_expansion_button_toggled(button_pressed):
	settings["Expansion"] = button_pressed
	_on_confirm_button_pressed()

func _on_expansion_stats_button_toggled(button_pressed):
	settings["Expansionsettings"] = button_pressed
	_on_confirm_button_pressed()

func _on_plus_button_pressed():
	settings["Rounds"] += 1
	$Rounds/Num.text = str(settings["Rounds"])
	_on_confirm_button_pressed()

func _on_minus_button_pressed():
	settings["Rounds"] -= 1
	$Rounds/Num.text = str(settings["Rounds"])
	_on_confirm_button_pressed()

func _on_confirm_button_pressed():
	var settings_file = FileAccess.open(settings_path, FileAccess.WRITE)
	settings_file.store_line(JSON.stringify(settings))
	settings_file.close()
	Settings.settings = settings
	$Confirm.visible = false


func _on_restore_button_pressed():
	settings = {
			"Split": true,
			"Second": false,
			"Expansion": false,
			"ExpansionStats": false,
			"Rounds": 3
		}
	$Split/SplitButton.button_pressed = true
	$Second/SecondButton.button_pressed = false
	$Expansion/ExpansionButton.button_pressed = false
	$ExpansionStats/ExpansionStatsButton.button_pressed = false
	$Rounds/Num.text = "3"
	_on_confirm_button_pressed()

func _on_reset_button_pressed():
	$Popup.visible = true


func _on_cancel_button_pressed():
	$Popup.visible = false


func _on_confirm_reset_button_pressed():
	DirAccess.remove_absolute(stats_path)
	DirAccess.remove_absolute(players_path)
	for i in Settings.matchups.values():
		DirAccess.remove_absolute(Settings.version+"://stats"+str(i)+".save")
		DirAccess.remove_absolute(Settings.version+"://players"+str(i)+".save")
	DirAccess.remove_absolute(Settings.matchups_path)
	Settings.matchups = {}
	$Popup.visible = false

func _on_close_button_pressed():
	$TooltipPopup.visible = false


func _on_tooltip_pressed():
	$TooltipPopup.visible = true
