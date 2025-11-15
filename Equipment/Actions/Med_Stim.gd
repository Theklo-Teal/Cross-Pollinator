extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 0


func setup():
	slot = Character.K.OTHER
	title = "Medical Stimulants"
	description = "An Agarthian concotion of cellular stimulants that enhances health regeneration during combat."
