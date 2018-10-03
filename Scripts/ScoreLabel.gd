extends Label

var score = 0

func _ready():
	var saved_state = Game.get_state_from_savefile(name)
	for prop in saved_state:
		set(prop, saved_state[prop])
	text = str(score)
func update_score(points):
	score += points
	set_text(str(score))
	Game.save_game()
	
func save():
	var save_dict = {
		"name": name,
		"data" : {	
			"score": score
		}
	}
	return save_dict