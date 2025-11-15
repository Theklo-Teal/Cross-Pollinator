extends "res://Equipment/Actions/throw.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 3

func setup():
	super()
	title = "Proximity Scanner"
	description = "Throws a tiny ball probe of Agarthian design equipped with motion sensors and sonar that can reveal characters in concealment."
