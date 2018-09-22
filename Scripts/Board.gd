extends GridContainer

export (int) var board_width = 8
export (int) var board_height = 8

#NOTE: TO SET PADDING, USE "Vseparation" AND "Hseparation" UNDER "Custom Constants" IN INSPECTOR!

var socket_scene = preload("res://Scenes/Socket.tscn")

func _ready():
	randomize()
	for index in range(board_height * board_width):
		var socket = socket_scene.instance()
		add_child(socket)