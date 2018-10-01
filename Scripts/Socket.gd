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
func handle_match():
	#tells gem to destroy itself
	#sets gem to null after animations
	
	gem.destroy()
	yield(gem.animation_player, "animation_finished")
	status = Socket_Status.GENERATION_QUEUED
	gem = null

func handle_swap(direction, replacement_symbol, reverse_direction = false):
	if reverse_direction:
		if direction == Swap_Direction.RIGHT:
			direction = Swap_Direction.LEFT
		elif direction == Swap_Direction.LEFT:
			direction = Swap_Direction.RIGHT
		elif direction == Swap_Direction.UP:
			direction = Swap_Direction.DOWN
		elif direction == Swap_Direction.DOWN:
			direction = Swap_Direction.UP
		
	if direction == Swap_Direction.RIGHT:
		gem.animation_player.play("Swap_Right")
	if direction == Swap_Direction.LEFT:
		gem.animation_player.play("Swap_Left")
	if direction == Swap_Direction.UP:
		gem.animation_player.play("Swap_Up")
	if direction == Swap_Direction.DOWN:
		gem.animation_player.play("Swap_Down")
	
	yield(gem.animation_player, "animation_finished")
	remove_child(gem)
	gem.queue_free()
	var replacement = gem_preload.instance()
	replacement.symbol = replacement_symbol
	replacement.get_node("Sprite").scale = Vector2(0.5,0.5)
	add_child(replacement)
	gem = replacement
	
	
func generate_gem():
	#print(get_child(0).name)
	if not gem:
		gem = gem_preload.instance()
		gem.rect_min_size = Vector2(0,0)
		gem.rect_size = Vector2(0,0)
		gem.set_symbol(randi() % gem.Symbols.size())
		add_child(gem, true)
		gem.animation_player.play("Placeholder_Generate")

func is_screen_dragging_or_mouse_moving(e):
	var is_mouse_moving = e is InputEventMouseMotion and e.button_mask == BUTTON_MASK_LEFT
	var is_screen_dragging = e is InputEventScreenDrag
	return is_mouse_moving or is_screen_dragging
	
func _gui_input(event):

	var idle = current_board.play_state == current_board.IDLE
		
	if is_screen_dragging_or_mouse_moving(event) and idle:# and Game.current_gamestate == Game.GameState.GEM_TOUCHED:
		var direction = determine_swipe_direction(event.position)
		var target_index = find_swap_target_index(direction)
		
		if (target_index > -1):
			current_board.swap_start_socket = grid_index
			current_board.swap_end_socket = target_index
			current_board.swap_direction = direction
			current_board.play_state = current_board.SWAPPING

func determine_swipe_direction(cursor_pos):
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