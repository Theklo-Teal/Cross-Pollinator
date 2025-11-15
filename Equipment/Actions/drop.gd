extends CharacterAction

func set_icon():
	super()
	icon_texture = preload("res://Assets/Textures/action_atlas_tall.tres")
	icon_texture.region.size = Vector2(64, 128)

func setup():
	slot = Character.K.DEPL
	title = "Generic Throwable"
