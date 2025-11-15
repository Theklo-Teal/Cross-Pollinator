extends "res://Equipment/Actions/long_rifle.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 9


func setup():
	super()
	title = "Orgone Stun Gun"
	description = "A prototype anti-Agarthian weapon which launches ectoplasm pellets that overwhelm their senses by jamming their orgone sensing neurons. It can also cause extreme cooling, which is effective at hurting and freezing other humans."
