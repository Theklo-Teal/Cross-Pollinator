extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 10


func setup():
	slot = Character.K.OTHER
	title = "Taunt"
	description = "Increases the chance that this character will be targeted by enemies in lieu of more advantageous allies."
