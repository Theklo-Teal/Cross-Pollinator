extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 4


func setup():
	slot = Character.K.RAISE
	title = "Suppression"
	description = "Fire a constant stream of bullets at enemy cover to dissuade them from coming out
[ul]Reduces the hit chance from any attack from the target[/ul]
[ul]There's a chance of hitting the enemy if they attempt to move[/ul]"
