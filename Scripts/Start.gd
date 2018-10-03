extends Control



func _on_StartButton_button_up():
	$SceneFadeOut/AnimationPlayer.play("GameStart")
	

func start_game():
	get_tree().change_scene("res://Scenes/ZenMode.tscn")