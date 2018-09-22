extends Control

export (Vector2) var size = Vector2(64,64)
onready var gem = $Gem
func _ready():
	rect_min_size = size
	gem.rect_min_size = size
	gem.set_symbol(randi() % gem.Symbols.size())