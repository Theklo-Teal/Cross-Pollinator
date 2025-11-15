extends "res://Equipment/Actions/throw.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 1


func setup():
	super()
	title = "Frag Grenade"
	description = "Throws a grenade with a wide blast radius that is capable of destroying cover and harming enemies with modest damage."
