extends TacticsState


func _entering(prev):
	# Set up the game rules to the start, then let player control the characters.
	
	me.clear_plots()
	me.require_UI(["Subtitles", "Player_UI"])
	
	if prev == null:
		# It's the start of a new game.
		#TODO Center camera on the selected character.
		my("Cam").disabled = false


func _unhandled_event(event:InputEvent):
	if event is InputEventMouseMotion:
		if not Ses.curr_unit().is_busy() and not Ses.mouse_map == null:
			var plot = Ses.mouse_map.get_trajectory(Ses.curr_unit(), Ses.mouse_cell)
			me.plot_on_grid(plot)
	
	if event is InputEventMouseButton:
		if not Ses.curr_unit().is_busy() and not Ses.mouse_map == null:
			if event.is_action_released("chara_action"):
				Ses.curr_unit().set_state("Walk", Ses.mouse_cell)


func _character_interaction(_chara:Character):
	return true
