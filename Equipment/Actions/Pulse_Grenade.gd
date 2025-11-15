extends "res://Equipment/Actions/throw.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 1

func setup():
	title = "EMP Grenade"
	description = "A small explosive that excites a magnetic coil producing high intensity and broad spectrum electrical noise that disables sensitive electronics."
