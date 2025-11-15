extends TacticsState

func _entering(_prev_state:TacticsState):
	me.require_UI(["Subtitles"])

func _unhandled_event(event:InputEvent):
	if event is InputEventMouseButton:
		pass  ## Progress interaction

func _character_interaction(chara):
	# Interaction complete. Leaving interation.
	if chara == me.curr_unit():
		me.prev_state()
	return true
