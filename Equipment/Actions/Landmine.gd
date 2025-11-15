extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 11


func setup():
	slot = Character.K.OTHER
	title = "Lay Mine"
	description = "Place an hidden explosive that detonates if an enemy steps on its tile.
[ul]Enemies don't evade rigged tiles.[/ul]
[ul]Causes modest damage[/ul]
[ul]Triggers on an enemy moving through the target tile[/ul]
[ul]Triggers on an enemy stopping on the target tile[/ul]"
