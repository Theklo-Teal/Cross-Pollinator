extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 3


func setup():
	slot = Character.K.RAISE
	title = "Flush Out"
	description = "Fire at enemy cover to force them to get exposed.
[ul]Guarantees destroying cover adjacent to the target[/ul]
[ul]Enemy will perform a move out of turn[/ul]"
