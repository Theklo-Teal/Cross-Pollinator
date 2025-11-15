extends "res://Equipment/Actions/throw.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 1

func setup():
	super()
	title = "Warp Beacon"
	description = "Throws a GPS beacon which designates a target where the Cross Pollinator is being requested to open up. Characters can then disappear from the battlefield and be made to appear somewhere else."
