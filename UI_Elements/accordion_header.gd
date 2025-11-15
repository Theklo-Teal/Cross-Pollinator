@tool
extends Control

signal pressed()
signal toggled(toggled_on)

var button : Button

@export var text : String : set = set_text
@export var disabled : bool : set = set_disabled
@export var button_pressed : bool : set = set_pressed
@export var button_group : ButtonGroup
@export var update_themes : bool : set = update_settings
@export_group("Button Theme")
@export var button_theme_normal : StyleBox
@export var button_theme_hover : StyleBox
@export var button_theme_pressed : StyleBox
@export var button_theme_focus : StyleBox
@export_group("Text Theme")
@export_enum("Left", "Center", "Right") var text_alignment : int
@export var font_family : Font
@export var font_size : int
@export var font_color : Color

func set_text(val:String):
	text = val
	if is_node_ready():
		button.text = val

func set_disabled(val:bool):
	disabled = val
	if is_node_ready():
		button.disabled = val

func set_pressed(val:bool):
	button_pressed = val
	if is_node_ready():
		button.button_pressed = val

func update_settings(val:bool):
	if val:
		if button_theme_normal:
			button.add_theme_stylebox_override("normal", button_theme_normal)
		if button_theme_hover:
			button.add_theme_stylebox_override("hover", button_theme_hover)
		if button_theme_pressed:
			button.add_theme_stylebox_override("pressed", button_theme_pressed)
		if button_theme_focus:
			button.add_theme_stylebox_override("focus", button_theme_focus)
		button.alignment = text_alignment
		button.add_theme_font_size_override("font_size", font_size)
		button.add_theme_color_override("font_color", font_color)
		if font_family != null:
			button.add_theme_font_override("font", font_family)

func _ready():
	
	button = Button.new()
	button.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_KEEP_HEIGHT)
	add_child(button, false, Node.INTERNAL_MODE_FRONT)
	
	button.text = text
	button.disabled = disabled
	button.toggle_mode = true
	button.button_pressed = button_pressed
	button.button_group = button_group
	
	_on_accordion_header_toggled(button_pressed)
	button.toggled.connect(_on_accordion_header_toggled)
	button.pressed.connect(_on_accordion_header_pressed)

	update_settings(true)

func _on_accordion_header_toggled(press_on:bool):
	for each in get_children(false):
		each.visible = press_on
	toggled.emit(press_on)
	
func _on_accordion_header_pressed():
	pressed.emit()
