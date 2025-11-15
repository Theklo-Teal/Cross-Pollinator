extends "res://Equipment/Actions/throw.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 2


func setup():
	super()
	title = "Flashbang"
	description = "Throws a grenade with a wide blast radius that will blind enemies for 2 turns."
