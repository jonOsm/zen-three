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

