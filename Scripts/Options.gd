extends PopupPanel


signal change_music_volume(ratio)
signal change_SFX_volume(ratio)


func _on_MusicVolumeSlider_value_changed(value):
	var ratio = value/100
	$MusicControls/MusicVolumeLabel.text = str(value)
	emit_signal("change_music_volume", ratio)



func _on_SFXVolumeSlider_value_changed(value):
	var ratio = value/100
	$SFXControls/SFXVolumeLabel.text = str(value)
	emit_signal("change_SFX_volume", ratio)

func _on_Quit_button_down():
	hide()
