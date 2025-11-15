extends CharacterAction

func set_icon():
	super()
	icon_texture.region.position.y = icon_texture.region.size.y * 2


func setup():
	slot = Character.K.LOWER
	title = "Low Profile"
	description = "Become less of a target by squeezing against cover or lying prone on the ground.\n[ul]Reduces hit chance on attacks on this unit.[/ul]\n[ul]Unit moves more cautiously and won't vault obstacles.[/ul]"

func entering(arg=null):
	if me.stance == Character.STANCE.LOWER:
		me.stance = Character.STANCE.NOMIN
	else:
		me.stance = Character.STANCE.LOWER
	
	me.call_deferred("set_state", "Idle")
