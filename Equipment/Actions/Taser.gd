extends "res://Equipment/Actions/handgun.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 9


func setup():
	super()
	title = "Taser Pistol"
	description = "It fires a wired dart a target with a chance of disabling their next turn."
