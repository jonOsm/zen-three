extends PopupPanel


signal change_music_volume(ratio)
signal change_SFX_volume(ratio)
var music_volume = 100
var sfx_volume = 50

func _ready():
	var state = Game.get_state_from_savefile(name)
	for prop in state:
		set(prop, state[prop])	
	update_music_volume()
	update_SFX_volume()
	$MusicControls/MusicVolumeSlider.value = music_volume
	$SFXControls/SFXVolumeSlider.value = sfx_volume
	
func _on_MusicVolumeSlider_value_changed(value):
	music_volume = value
	update_music_volume()

func update_music_volume():
	var ratio = music_volume/100
	$MusicControls/MusicVolumeLabel.text = str(music_volume)
	emit_signal("change_music_volume", ratio)
	
func _on_SFXVolumeSlider_value_changed(value):
	sfx_volume = value
	update_SFX_volume()
	
func update_SFX_volume():
	var ratio = sfx_volume/100
	$SFXControls/SFXVolumeLabel.text = str(sfx_volume)
	emit_signal("change_SFX_volume", ratio)

func save():
	var save_dict = {
		"name": name,
		"data" : {	
			"music_volume": music_volume,
			"sfx_volume": sfx_volume
		}
	}
	return save_dict

func _on_Back_pressed():
	Game.save_game()
	hide()
