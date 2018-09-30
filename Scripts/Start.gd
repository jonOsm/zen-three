extends Control



func _on_StartButton_button_up():
	print("clicked")
	get_tree().change_scene("res://Scenes/ZenMode.tscn")
