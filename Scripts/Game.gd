extends Node2D

export (int) var board_width = 8
export (int) var board_height = 8
var padding = 20
var gem_scene = preload("res://Scenes/Gem.tscn")
var board = []
func _ready():
	setup_board()
	
	
func setup_board():
	for i in range (board_width*board_height):
		var gem = gem_scene.instance()
		randomize()
		gem.symbol = randi() % gem.Symbols.size()
		board.append(gem)
		add_child(gem)
		
		var is_first_column = bool(i % board_width)
		var xpos = (gem.size * i)
		xpos -= floor(i/board_width) * gem.size * board_width
		xpos += (i % board_width) * padding
		
		var ypos = gem.size * int(i/board_width)
		ypos += floor(i / board_height) * padding
		gem.position = Vector2(xpos, ypos)
		
		
