extends "res://Equipment/Actions/long_rifle.gd"

func get_bonus_actions() -> Array[String]:
	return ["Grenade_Launcher", "Flush_Out"]

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 7

func setup():
	super()
	title = "Battle Rifle"
	description = "The standard issue carbine of the military. As per manual of arms, it's used in semi-auto fire, but fires high power cartridges with good accuracy. It includes an under-slug grenade launcher for convinience."
