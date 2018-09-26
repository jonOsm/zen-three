extends Control

enum Socket_Status {
	AWAITING_INPUT,
	GENERATION_QUEUED,
	#GENERATING,
	DESTRUCTION_QUEUED,
	#DESTROYING
}

export (Vector2) var size = Vector2(64,64)
var swipe_speed_threshold = 70
var grid_index
var current_board
var gem_preload = preload("res://Scenes/Gem.tscn")
var gem
var status = Socket_Status.AWAITING_INPUT
var is_animating

enum Swap_Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT,
	NONE
}
export (bool) var debugging = false
export (float) var swap_back_delay = 0.5

func _ready():
	rect_min_size = size
	rect_size = size
	generate_gem()
	current_board.connect("refill_sockets",self, "generate_gem")
	
	if debugging:
		
		var index_label = Label.new()
		index_label.text = str(grid_index)
		index_label.align = HALIGN_CENTER
		index_label.valign = VALIGN_CENTER
		
		add_child(index_label)

func generate_gem():
	#print(get_child(0).name)
	if not gem:
		gem = gem_preload.instance()
		gem.rect_min_size = Vector2(0,0)
		gem.rect_size = Vector2(0,0)
		gem.set_symbol(randi() % gem.Symbols.size())
		gem.connect("gem_animation_complete", self, "set_is_animating")
		gem.connect("gem_animation_started", self, "set_is_animating")
		add_child(gem, true)
		
func set_is_animating(value):
	is_animating = value
		
func _gui_input(event):
	if Game.current_gamestate == Game.GameState.RESOLVING_MATCHES or Game.current_gamestate == Game.GameState.LOCKED:
		return
		
	if event is InputEventScreenDrag:
		pass #IMPLEMENT IF NECESSARY
		
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		Game.current_gamestate = Game.GameState.GEM_TOUCHED
	
	#might need to move this into mouse drag event below
	if event is InputEventMouseButton and event.is_action_released("left_click") and event.button_index == BUTTON_LEFT:
		Game.current_gamestate = Game.GameState.IDLE
		
	if event is InputEventMouseMotion and event.button_mask == BUTTON_MASK_LEFT and Game.current_gamestate == Game.GameState.GEM_TOUCHED:
		
		var direction = determine_swipe_direction(event)
		var target_index = find_swap_target_index(direction)
		if (target_index > -1):
			
			
			#swap ownership of gem
			var target_socket = current_board.get_children()[target_index]
			var gem_at_target = target_socket.gem
			var gem_here = gem
			remove_child(gem)
			target_socket.remove_child(target_socket.gem)
			add_child(gem_at_target)
			target_socket.add_child(gem_here)
			target_socket.gem = gem
			gem = gem_at_target

			Game.current_gamestate = Game.GameState.SWAPPING
			
			#check for match
			var match_found = current_board.queue_matches(grid_index, target_index)
			if match_found:
				Game.current_gamestate = Game.GameState.RESOLVING_MATCHES
			else:
				Game.current_gamestate = Game.GameState.LOCKED
				yield(get_tree().create_timer(swap_back_delay), "timeout")
				target_socket = current_board.get_children()[target_index]
				gem_at_target = target_socket.gem
				gem_here = gem
				remove_child(gem)
				target_socket.remove_child(target_socket.gem)
				add_child(gem_at_target)
				target_socket.add_child(gem_here)
				target_socket.gem = gem
				gem = gem_at_target
				Game.current_gamestate = Game.GameState.IDLE

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