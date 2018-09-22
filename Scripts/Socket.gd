extends Control

export (Vector2) var size = Vector2(64,64)

func _ready():
	rect_min_size = size