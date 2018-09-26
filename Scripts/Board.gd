extends GridContainer

export (int) var board_width = 8
export (int) var board_height = 8

var sockets = []
#NOTE: TO SET PADDING, USE "Vseparation" AND "Hseparation" UNDER "Custom Constants" IN INSPECTOR!
var socket_scene = preload("res://Scenes/Socket.tscn")
var gem = preload("res://Scenes/Gem.tscn")

var queued_matches = []
var newly_generated = []
var generation_timer = 0
signal refill_sockets
signal match_resolved
func _ready():
	randomize()
	var new_gem = gem.instance()
	
	regenerate_board()

func regenerate_board():
	if get_child_count() > 0:
		for socket in get_children():
			remove_child(socket)
			
	for index in range(board_height * board_width):
		var socket = socket_scene.instance()
		socket.grid_index = index
		socket.current_board = self
		sockets.append(socket)
		add_child(socket)
	newly_generated = range(get_child_count())
	Game.current_gamestate = Game.GameState.CHECKING_NEWLY_GENERATED

func _process(delta):
	if Game.current_gamestate == Game.GameState.CHECKING_NEWLY_GENERATED:	
		for socket_index in newly_generated:
			var the_match = find_matches(socket_index, get_children()[socket_index].gem.symbol)
			if the_match.size() > 2:
				queued_matches.append(the_match)
		if queued_matches.size() > 0:
			Game.current_gamestate = Game.GameState.RESOLVING_MATCHES
		else:
			Game.current_gamestate = Game.IDLE
			
	elif Game.current_gamestate == Game.GameState.RESOLVING_MATCHES:
		if generation_timer < 0.7:
			generation_timer+=delta
		else:
			generation_timer = 0
			for socket in get_children():
				if socket.status == socket.Socket_Status.GENERATION_QUEUED:
					socket.generate_gem()
			Game.current_gamestate = Game.GameState.CHECKING_NEWLY_GENERATED
			
		for m in queued_matches:
			handle_match(m)
			emit_signal("match_resolved", m.size()) #used in zen mode script to increase score
		queued_matches = []
		
#TODO: DON'T HAVE BOARD TALK DIRECTLY TO GEM, GO THROUGH SOCKET
func handle_match(the_match):
	var all_sockets = get_children()
	for socket_index in the_match:
		var socket = all_sockets[socket_index]
		if socket.gem:
			socket.status = socket.Socket_Status.GENERATION_QUEUED
			socket.gem.destroy()
			socket.gem = null
			#socket.generate_gem()
	
			

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		regenerate_board()
		
func socket_count():
	return sockets.size()
	
func queue_matches(start_socket_index, target_socket_index):
	
	var match_found = false
	#matching logic done here
	#do this before even swaping?
	
	print("check for match called")
	#get all the children of board
	var all_sockets = get_children()
	
	#check current sockets gem with target sockets column and row
	var start_socket_symbol = all_sockets[start_socket_index].gem.symbol
	var start_socket_matches = find_matches(start_socket_index, start_socket_symbol)

	#check target sockets gem with current sockets column and row
	var target_socket_symbol = all_sockets[target_socket_index].gem.symbol
	var target_socket_matches = find_matches(target_socket_index, target_socket_symbol)
	
	if target_socket_matches.size() > 2:
		queued_matches.append(target_socket_matches)
		match_found = true
		
	if start_socket_matches.size() > 2:
		queued_matches.append(start_socket_matches)
		match_found = true
	
	return match_found
	
func find_matches(start_index, symbol):
	var sockets_snapshot = get_children()
	var consecutive_up_matches = []
	for up in range(start_index-board_width, 0, -board_width):
		if sockets_snapshot[up].gem.symbol == symbol:
			consecutive_up_matches.append(up)
		else:
			break
	
	var consecutive_down_matches = []
	for down in range(start_index+board_width, board_height*board_width, board_width):
		if sockets_snapshot[down].gem.symbol == symbol:
			consecutive_down_matches.append(down)
		else:
			break
	
	var vertical_matches = [start_index] + consecutive_up_matches + consecutive_down_matches

	var consecutive_left_matches = []
	var final_left_index = start_index - (start_index % board_width)
	for left in range(start_index-1, final_left_index-1, -1):
		#print("current symbol: " + str(symbol) + ", up symbol: " + str(sockets_snapshot[up].get_node("Gem").symbol))
		if sockets_snapshot[left].gem.symbol == symbol:
			consecutive_left_matches.append(left)
			#print("up found")
		else:
			break #we don't want to keep checking, matches MUST be consecutive
	
	var consecutive_right_matches = []
	var final_right_index = start_index + (board_width - (start_index%board_width))
	for right in range(start_index+1, final_right_index, 1):
		if sockets_snapshot[right].gem.symbol == symbol:
			consecutive_right_matches.append(right)
		else:
			break
	
	var horizontal_matches = [start_index] + consecutive_left_matches + consecutive_right_matches
	#note that this will prefer horizontal maches over vertical matches
	if horizontal_matches.size() >= vertical_matches.size():
		return horizontal_matches
	
	return vertical_matches
	#return max of vertical or horizontal matches