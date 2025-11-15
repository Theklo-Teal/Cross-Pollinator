extends "res://Equipment/Actions/long_rifle.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 9

func setup():
	super()
	title = "Transrekto SL"
	description = "A chemical laser used by Agarthian sniper units. Completely silent, It doesn't remove Concealment when used."
