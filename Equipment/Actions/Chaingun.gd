extends "res://Equipment/Actions/long_rifle.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 8

func setup():
	super()
	title = "Chaingun"
	description = "A gun which feeds intermediate cartridges from a belt, intended for sustained suppressive fire which acts as deterrance on the battle field."

func get_bonus_actions() -> Array[String]:
	return ["Suppression"]
