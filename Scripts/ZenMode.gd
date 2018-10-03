extends Node2D
	
var menu_open = false
onready var board = $CanvasLayer/CenterContainer/Board
var score_label #can't use onready since 
onready var sfx_player = $GeneralSFX
export (float) var default_pitch = 0.7
var score = 0

func _ready():
	#Game.load_game()
	board.connect("match_resolved", self, "on_Match_Resolved")
	score_label = $CanvasLayer/ScoreLabel
	
func on_Match_Resolved(magnitude):
	update_score(magnitude)
	sfx_player.pitch_scale = default_pitch
	if magnitude >= 5:
		sfx_player.pitch_scale = default_pitch+0.3
	elif magnitude >= 4:
		sfx_player.pitch_scale = default_pitch+0.15
	sfx_player.play()
	
func update_score(match_magnitude):
	var points = (3*pow(2,match_magnitude-3))
	score_label.update_score(points)
	
	
func _on_Button_button_down():
	$CanvasLayer/PopupPanel.popup()
	menu_open = true

func _on_CloseMenu_button_up():
	print("running?")
	$CanvasLayer/PopupPanel.hide()
	menu_open = false


func _on_SoundOptions_change_music_volume(ratio):
	#note: -60 is the limit of human hearing (maybe?) so it's our min value
	#note: 0 is the max volume before distortion
	if ratio <= 0:
		$BGM.volume_db = -80 #lowest decibel value allowed
		return

	var decibels = (1-ratio) * -25
	$BGM.volume_db = decibels

func _on_SoundOptions_change_SFX_volume(ratio):
	for stream in get_tree().get_nodes_in_group("sfx_streams"):
		if ratio <= 0:
			stream.volume_db = -80 #lowest decibel value allowed
		else:
			var decibels = (1-ratio) * -60
			stream.volume_db = decibels

func _on_OptionsButton_button_down():
	$CanvasLayer/Options.popup()
