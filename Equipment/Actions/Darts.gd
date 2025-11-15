extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 9


func setup():
	super()
	slot = Character.K.OTHER
	title = "Homing Darts"
	description = "A barrage of guided missiles is unloaded at a target to shred them."
