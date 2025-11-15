extends "res://Equipment/Actions/handgun.gd"

func get_bonus_perks() -> Array[String]:
	return ["SilentShot_Perk"]

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 5

func setup():
	super()
	title = "Pistol"
	description = "Fires multiple shots of your semi-automatic pistol at a target under line of sight.
[ul][b]Enables Perk:[/b]
[ul]Silent Shot[/ul]
[/ul]"
