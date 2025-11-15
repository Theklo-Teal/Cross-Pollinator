extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 1


func setup():
	slot = Character.K.RAISE
	title = "Overwatch"
	description = "Permission to fire at will on any enemy target that moves within range."
