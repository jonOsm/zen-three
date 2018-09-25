extends Node
enum GameState {
	IDLE
	GEM_TOUCHED,
	SWAPPING,
	RESOLVING_MATCHES,
	LOCKED
}

var current_gamestate = GameState.IDLE