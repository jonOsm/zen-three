extends GridContainer

export (int) var board_width = 8
export (int) var board_height = 8

var sockets = []
#NOTE: TO SET PADDING, USE "Vseparation" AND "Hseparation" UNDER "Custom Constants" IN INSPECTOR!
var socket_scene = preload("res://Scenes/Socket.tscn")

func _ready():
	randomize()
	for index in range(board_height * board_width):
		var socket = socket_scene.instance()
		socket.grid_index = index
		socket.current_board = self
		sockets.append(socket)
		add_child(socket)

func socket_count():
	return sockets.size()