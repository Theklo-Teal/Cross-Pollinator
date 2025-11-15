extends "res://Equipment/Actions/handgun.gd"

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 9


func setup():
	super()
	title = "Diverfleksanto"
	description = "A strange handgun mounted on a robotic arm which Agarthians use to shoot without requiring to aim."
