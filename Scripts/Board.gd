extends GridContainer

export (int) var board_width = 8
export (int) var board_height = 8

var sockets = []
#NOTE: TO SET PADDING, USE "Vseparation" AND "Hseparation" UNDER "Custom Constants" IN INSPECTOR!
var socket_scene = preload("res://Scenes/Socket.tscn")
var queued_matches = []
signal refill_sockets

func _ready():
	randomize()
	for index in range(board_height * board_width):
		var socket = socket_scene.instance()
		socket.grid_index = index
		socket.current_board = self
		sockets.append(socket)
		add_child(socket)


func _process(delta):
		
	if Game.current_gamestate == Game.GameState.RESOLVING_MATCHES:
		for m in queued_matches:
			handle_match(m)
		queued_matches = []
		#emit_signal("refill_sockets")
		Game.current_gamestate = Game.GameState.IDLE
			
func handle_match(the_match):
	var all_sockets = get_children()
	for socket_index in the_match:
		all_sockets[socket_index].get_node("Gem").queue_free()

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