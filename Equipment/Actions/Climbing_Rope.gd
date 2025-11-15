extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 12


func setup():
	slot = Character.K.OTHER
	title = "Climbing Rope"
	description = "Either by dropping a rope or throwing a grappling hook, a new valid path between tiles at different altitudes is created."
