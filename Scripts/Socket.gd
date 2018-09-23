extends Control

export (Vector2) var size = Vector2(64,64)
var swipe_speed_threshold = 25
var grid_index
var current_board
enum Swap_Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT,
	NONE
}

func _ready():
	rect_min_size = size
	rect_size = size
	$Gem.rect_min_size = size
	$Gem.set_symbol(randi() % $Gem.Symbols.size())
	
func _gui_input(event):
	#print(event.as_text())
	if event is InputEventScreenDrag:
		pass #IMPLEMENT IF NECESSARY
		
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		Game.current_gamestate = Game.GameState.GEM_TOUCHED
	
	#might need to move this into mouse drag event below
	if event is InputEventMouseButton and event.is_action_released("left_click") and event.button_index == BUTTON_LEFT:
		print("changing gamestate to IDLE")
		Game.current_gamestate = Game.GameState.IDLE
		
	if event is InputEventMouseMotion and event.button_mask == BUTTON_MASK_LEFT and Game.current_gamestate == Game.GameState.GEM_TOUCHED:
		
		var direction = determine_swipe_direction(event)
		var target_index = find_swap_target_index(direction)
		if (target_index > -1):
			var target_socket = current_board.get_children()[target_index]
			var gem_at_target = target_socket.get_node("Gem")
			var gem_here = $Gem
			remove_child(gem_here)
			target_socket.remove_child(target_socket.get_node("Gem"))
			add_child(gem_at_target)
			target_socket.add_child(gem_here)
			
			Game.current_gamestate = Game.GameState.SWAPPING
			
			
			#$Gem = gem_at_target
		


func determine_swipe_direction(event):
	#as long as at least one of the speed components are less than the thresshold
	#run swapping code -- this is in case someone swaps on the diagonal
	if abs(event.speed.x) < swipe_speed_threshold or abs(event.speed.y) < swipe_speed_threshold:		
		if event.speed.x > swipe_speed_threshold:
			return Swap_Direction.RIGHT	
		elif event.speed.x < -swipe_speed_threshold:
			return Swap_Direction.LEFT

		if event.speed.y > swipe_speed_threshold:
			return Swap_Direction.DOWN
		elif event.speed.y < -swipe_speed_threshold:
			return Swap_Direction.UP
	return Swap_Direction.NONE

#TODO: improve this by returning a dictionary containing index
# and STATUS. e.g., sucess, no-gem-found-in-swap-direction, speed?
#this would allow us to animated based on both index AND status
func find_swap_target_index(direction):
	match(direction):
		Swap_Direction.UP:
			var i = grid_index - current_board.board_width
			if i >= 0:
				return i
		Swap_Direction.RIGHT:
			var i = grid_index + 1
			if i % current_board.board_width:
				return i
		Swap_Direction.DOWN:
			var i = grid_index + current_board.board_width
			if i < current_board.socket_count():
				return i
		Swap_Direction.LEFT:
			if grid_index % current_board.board_width:
				return grid_index - 1
	return -1