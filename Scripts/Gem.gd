extends Control

#should be class level, how do you make this static in GDSCRIPT?
enum Symbols {
	TRIANGLE,
	SQUARE,
	DIAMOND,
	PENTAGON,
	STAR,
	CIRCLE
	}
	
const symbol_colors = {
	Symbols.TRIANGLE: Color(0,1,0), #green
	Symbols.SQUARE: Color(0,0,1), #blue
	Symbols.DIAMOND: Color(1,0,0), #red
	Symbols.PENTAGON: Color(1,0,1), #purple
	Symbols.STAR:Color(1,1,0),
	Symbols.CIRCLE: Color(.75,1,1)
}

var symbol_img = {
	Symbols.TRIANGLE: "res://Assets/PNG/Tiles green/tileGreen_31.png",
	Symbols.SQUARE: "res://Assets/PNG/Tiles blue/tileBlue_37.png",
	Symbols.DIAMOND: "res://Assets/PNG/Tiles red/tileRed_40.png",
	Symbols.PENTAGON: "res://Assets/PNG/Tiles orange/tileOrange_40.png",
	Symbols.STAR: "res://Assets/PNG/Tiles yellow/tileYellow_45.png",
	Symbols.CIRCLE: "res://Assets/PNG/Tiles black/tileBlack_47.png"
}

var symbol = Symbols.SQUARE
var size = 96
signal gem_animation_complete
signal gem_animation_started
signal gem_destruction_complete

func _ready():
	rect_min_size = Vector2(0,0)
	#$Sprite.offset = Vector2(size/2, size/2)
	set_texture_to_img()
	if not $Sprite.texture:
		pass
		#set_texture_to_placeholder()
	$AnimationPlayer.play("Placeholder_Generate")

func set_symbol(new_symbol):
	symbol = new_symbol
	set_texture_to_img()
	#set_texture_to_placeholder()
	
func set_texture_to_img():
	
#	var placeholder_texture = ImageTexture.new()
#
#	placeholder_texture.create_from_image()
	var img = load(symbol_img[symbol])
	
	$Sprite.texture = img
	
func set_texture_to_placeholder():
	var placeholder_img = Image.new()
	placeholder_img.create(size,size,false, Image.FORMAT_RGBAH)
	placeholder_img.fill(symbol_colors[symbol])
	var placeholder_texture = ImageTexture.new()
	
	placeholder_texture.create_from_image(placeholder_img)
	$Sprite.texture = placeholder_texture
func destroy():
	$AnimationPlayer.play("Placeholder_Destroy")
	yield(get_node("AnimationPlayer"), "animation_finished")
	queue_free()
	
func _animation_started():
	emit_signal("gem_animation_started", true)
func _animation_complete():
	emit_signal("gem_animation_complete", false)