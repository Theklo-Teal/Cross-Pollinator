extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 12


func setup():
	slot = Character.K.OTHER
	title = "Repairwork"
	description = "The character will regenerate health points to a robot in the field. If used on disabled enemy robots, it will also convert them to allies."
