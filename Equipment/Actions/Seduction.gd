extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 9


func setup():
	slot = Character.K.OTHER
	title = "Seduction"
	description = "Make some sensual moves, flash your assets, and dazzle your enemies, making them unwilling to hurt you. Also reduces the Sober stat, reducing hit chance of their attacks."
