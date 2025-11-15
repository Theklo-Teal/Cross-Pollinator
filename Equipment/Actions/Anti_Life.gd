extends "res://Equipment/Actions/long_rifle.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 9


func setup():
	super()
	title = "Anti-Life Weapon"
	description = "A response from Agarthians to the Orgone Stun Gun, this weapon induces panic and psychological depression on any human target."
