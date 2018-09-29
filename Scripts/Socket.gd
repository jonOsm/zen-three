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
onready var DEBUG_LABEL = Game.DEBUG_LABEL
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
	#rect_size = size
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
	
func is_touch_or_click_pressed(e):
	var is_touch = e is InputEventScreenTouch
	if is_touch and e.is_pressed():
		return true
		
	var is_click = e is InputEventMouseButton
	if is_click and e.is_pressed() and e.button_index == BUTTON_LEFT:
		return true
		
	return false

func is_touch_or_click_released(e):
	var is_touch = e is InputEventScreenTouch
	if is_touch and not e.is_pressed():
		return true
		
	var is_click = e is InputEventMouseButton
	if is_click and  not e.is_pressed() and e.button_index == BUTTON_LEFT:
		return true
		
	return false

func is_screen_dragging_or_mouse_moving(e):
	var is_mouse_moving = e is InputEventMouseMotion and e.button_mask == BUTTON_MASK_LEFT
	var is_screen_dragging = e is InputEventScreenDrag
	return is_mouse_moving or is_screen_dragging
	
func _gui_input(event):

	var idle = current_board.play_state == current_board.IDLE
		
	if is_screen_dragging_or_mouse_moving(event) and idle:# and Game.current_gamestate == Game.GameState.GEM_TOUCHED:
		print(event.as_text())
		var direction = determine_swipe_direction(event.position)
		var target_index = find_swap_target_index(direction)
		
		if (target_index > -1):
			current_board.swap_start_socket = grid_index
			current_board.swap_end_socket = target_index
			current_board.play_state = current_board.SWAPPING
			
			#swap ownership of gem
#			var target_socket = current_board.get_children()[target_index]
#			var gem_at_target = target_socket.gem
#			var gem_here = gem
#			remove_child(gem)
#			target_socket.remove_child(target_socket.gem)
#			add_child(gem_at_target)
#			target_socket.add_child(gem_here)
#			target_socket.gem = gem
#			gem = gem_at_target

			Game.current_gamestate = Game.GameState.SWAPPING

			#check for match
#			var match_found = current_board.queue_matches(grid_index, target_index)
#			if match_found:
#				Game.current_gamestate = Game.GameState.RESOLVING_MATCHES
#			else:
#				Game.current_gamestate = Game.GameState.LOCKED
#				yield(get_tree().create_timer(swap_back_delay), "timeout")
#				target_socket = current_board.get_children()[target_index]
#				gem_at_target = target_socket.gem
#				gem_here = gem
#				remove_child(gem)
#				target_socket.remove_child(target_socket.gem)
#				add_child(gem_at_target)
#				target_socket.add_child(gem_here)
#				target_socket.gem = gem
#				gem = gem_at_target
#				Game.current_gamestate = Game.GameState.IDLE

func determine_swipe_direction(cursor_pos):
	#as long as at least one of the speed components are less than the thresshold
	#run swapping code -- this is in case someone swaps on the diagonal
	var scale = 0.5
	var size = self.rect_size.x #x and y should be the same
	var center_offset = size/2
	var right_threshold = size + center_offset
	var left_threshold = -size * scale + center_offset
	var up_threshold = left_threshold
	var down_threshold = right_threshold
	var dl = ""
	if cursor_pos.x > right_threshold:
		return Swap_Direction.RIGHT
	
	if cursor_pos.x < left_threshold:
		dl = "left"
		return Swap_Direction.LEFT
	
	if cursor_pos.y > down_threshold:
		dl = "down"
		return Swap_Direction.DOWN
		
	if cursor_pos.y < up_threshold:
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