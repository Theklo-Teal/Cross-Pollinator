extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 1

func setup():
	slot = Character.K.OTHER
	title = "Grenade Launcher"
	description = "A tube that throws the grenades for you. These grenades also explode on impact or proximity to enemies. Causes heavy damage and cover destruction."
