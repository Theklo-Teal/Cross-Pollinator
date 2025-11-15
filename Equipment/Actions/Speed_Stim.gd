extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 0


func setup():
	slot = Character.K.OTHER
	title = "Speed Stimulants"
	description = "Substance produced by Agarthian armour which temporarily enhances reflexes and fast-twitch muscle fibers."
