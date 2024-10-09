extends Node

const version = "user"

var settings
const settings_path = version+"://settings.save"
var matchups
const matchups_path = version+"://matchups.save"

# Called when the node enters the scene tree for the first time.
func _ready():
	if FileAccess.file_exists(settings_path):
		var settings_file = FileAccess.open(settings_path, FileAccess.READ)
		var json_string = settings_file.get_line()
		var json = JSON.new()
		json.parse(json_string)
		settings = json.get_data()
		settings_file.close()
	else:
		settings = {
			"Split": true,
			"Second": false,
			"Expansion": false,
			"ExpansionStats": false,
			"Rounds": 3
		}
	if FileAccess.file_exists(matchups_path):
		var matchups_file = FileAccess.open(matchups_path, FileAccess.READ)
		var json_string = matchups_file.get_line()
		var json = JSON.new()
		json.parse(json_string)
		matchups = json.get_data()
		matchups_file.close()
	else:
		matchups = {}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
