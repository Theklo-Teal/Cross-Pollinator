extends "res://Equipment/Actions/handgun.gd"

func get_bonus_perks() -> Array[String]:
	return ["DoubleTap_Perk"]

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 6

func setup():
	super()
	title = "Submachinegun"
	description = "A personal defense weapon with high rate of fire, increasing the chances of hitting your moving targets."
