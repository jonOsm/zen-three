extends Node
enum GameState {
	IDLE
	GEM_TOUCHED,
	SWAPPING,
	RESOLVING_MATCHES,
	CHECKING_NEWLY_GENERATED
	LOCKED
}

var current_gamestate = GameState.IDLE