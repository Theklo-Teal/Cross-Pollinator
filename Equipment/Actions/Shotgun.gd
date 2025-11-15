extends "res://Equipment/Actions/long_rifle.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 7

func setup():
	super()
	title = "Pump Action Shotgun"
	description = "The standard issue shotgun of the military. Can use a variety of special ammunition, but for our purposes we only door breaching rounds. They can still hurt enemies at close range."
