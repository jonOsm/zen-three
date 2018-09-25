extends Node2D
	
var menu_open = false
onready var board = $CanvasLayer/CenterContainer/Board
onready var score_label = $CanvasLayer/ScoreLabel
var score = 0

func _ready():
	board.connect("match_resolved", self, "update_score")


func update_score(match_magnitude):
	score += (3*pow(2,match_magnitude-3))
	score_label.set_text(str(score))
	
	
func _on_Button_button_down():
	$CanvasLayer/PopupPanel.popup()
	menu_open = true
	


func _on_CloseMenu_button_up():
	print("running?")
	$CanvasLayer/PopupPanel.hide()
	menu_open = false

func _on_Quit_button_down():
	get_tree().change_scene("res://Scenes/Start.tscn")
	pass # replace with function body
