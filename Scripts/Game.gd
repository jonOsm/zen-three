extends Node
enum GameState {
	IDLE
	GEM_TOUCHED,
	SWAPPING,
	MATCHING,
	LOCKED
}

var current_gamestate = GameState.IDLE