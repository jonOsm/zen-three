extends Control

#should be class level, how do you make this static in GDSCRIPT?
enum Symbols {
	TRIANGLE,
	SQUARE,
	DIAMOND,
	TRAPAZOID,
	STAR,
	CIRCLE
	}
var symbol_colors = {
	Symbols.TRIANGLE: Color(0,1,0), #green
	Symbols.SQUARE: Color(0,0,1), #blue
	Symbols.DIAMOND: Color(1,0,0), #red
	Symbols.TRAPAZOID: Color(1,0,1), #purple
	Symbols.STAR:Color(1,1,0),
	Symbols.CIRCLE: Color(.75,1,1)
}
	

var symbol = Symbols.SQUARE
var board_index
var size = 32

func _ready():
	rect_min_size = Vector2(size,size)
	if not $Sprite.texture:
		set_texture_to_placeholder()

func set_symbol(new_symbol):
	symbol = new_symbol
	set_texture_to_placeholder()
	
	
func set_texture_to_placeholder():
	var placeholder_img = Image.new()
	placeholder_img.create(size,size,false, Image.FORMAT_RGBAH)
	placeholder_img.fill(symbol_colors[symbol])
	var placeholder_texture = ImageTexture.new()
	
	placeholder_texture.create_from_image(placeholder_img)
	$Sprite.texture = placeholder_texture