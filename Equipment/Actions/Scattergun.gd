extends "res://Equipment/Actions/handgun.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 5


func setup():
	super()
	title = "Scattergun"
	description = "A compact Agarthian weapon meant to be cheap and dismember enemies which would otherwise be too tough to just die. It causes a small directed explosion, much like a fragmentation grenade blast."
