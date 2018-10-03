extends Control

func save():
	var save_dict = {
		"filename" : get_filename(),
        "parent" : get_parent().get_path()
	}
	
	return save_dict