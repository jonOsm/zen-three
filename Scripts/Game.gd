extends Node
enum GameState {
	IDLE
	GEM_TOUCHED,
	SWAPPING,
	RESOLVING_MATCHES,
	CHECKING_NEWLY_GENERATED
	LOCKED
}

#var symbol_paths = {
#	Symbols.TRIANGLE: "res://Assets/PNG/Tiles green/tileGreen_07.png",
#	Symbols.SQUARE: "res://Assets/PNG/Tiles green/tileGreen_07.png",
#	Symbols.DIAMOND: "res://Assets/PNG/Tiles green/tileGreen_07.png",
#	Symbols.TRAPAZOID: "res://Assets/PNG/Tiles green/tileGreen_07.png",
#	Symbols.STAR: "res://Assets/PNG/Tiles green/tileGreen_07.png",
#	Symbols.CIRCLE: "res://Assets/PNG/Tiles green/tileGreen_07.png",
#}

var current_gamestate = GameState.IDLE
var DEBUG_LABEL
var game_data
func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	
	var save_nodes = get_tree().get_nodes_in_group("persist")
	var data = {}
	for node in save_nodes:
		var record = node.save()
		data[record.name] = record.data
	save_game.store_string(to_json(data))
	save_game.close()
	#game_data = data

func load_game():
	
	var save_game = File.new()
	
	if not save_game.file_exists("user://savegame.save"):
		return #so save data found
		
	save_game.open("user://savegame.save", File.READ)
	game_data = parse_json(save_game.get_as_text())
	save_game.close()
	
func get_state_from_savefile(name):	
	if not game_data.has(name):
		return {}
	return game_data[name]
		
func _ready():
	load_game()