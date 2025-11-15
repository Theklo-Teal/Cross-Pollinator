extends "res://Equipment/Actions/throw.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 1


func setup():
	super()
	title = "Smoke Bomb"
	description = "Throws a grenade which will give Concealment bonus to all characters in the area of effect."
