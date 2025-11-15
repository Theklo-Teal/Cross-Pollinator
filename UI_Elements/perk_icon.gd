extends TextureRect

func _ready():
	set_theme(preload("res://UI_Elements/Tooltip_Theme.tres"))

func _make_custom_tooltip(for_text:String):
	var element := RichTextLabel.new()
	element.custom_minimum_size.x = 300
	element.fit_content = true
	element.bbcode_enabled = true
	element.text = for_text
	return element
