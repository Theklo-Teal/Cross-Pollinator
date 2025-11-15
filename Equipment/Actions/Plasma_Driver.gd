extends "res://Equipment/Actions/handgun.gd"

func get_bonus_perks() -> Array[String]:
	return []

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 5

func setup():
	super()
	title = "Plasma Driver"
	description = "Agarthian weapon which drives a pellet of magnesium with a electric accelerator, becoming super-heated in the process. This results in a needle-thin jet of plasma, much like in a shaped charge explosive. It doesn't have much range or is very accurate, but can defeat any armour. The plasma also ionizes the target, propagating an electric discharge to multiple nearby enemies."
