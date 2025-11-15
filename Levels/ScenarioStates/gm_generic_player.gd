extends TacticsState

## This state manages what happens at the end and start of turns for the player.

var in_position := false  # _proc will be called every frame even if wait halts a particular instance of its execution. This stops that.
var ally_count : int  # How many characters are available to do actions.

func _proc(delta):
	# Move camera to focus on a player character.
	if not in_position:
		var Cam : Node3D = my("Cam")
		var Unit : Character = Ses.curr_unit()
		var cam_tgt = Vector3(Unit.position.x, Cam.position.y, Unit.position.z)
		Cam.position = Cam.position.move_toward(cam_tgt, delta * Cam.speed)
		if Cam.position.is_equal_approx(cam_tgt):
			in_position = true
			my("Cam").disabled = false

func _unhandled_event(event):
	# Select unit
	if event.is_action_released("next_unit"):
		act().select_next()
		me.clear_plots()
	elif event.is_action_released("prev_unit"):
		act().select_prev()
		me.clear_plots()
	
	if event is InputEventKey:
		act().on_event_key(event)
	
	if event is InputEventMouseMotion:
		if not Ses.mouse_map == null:
			act().on_mouse_motion(event.position)
	
	if event is InputEventMouseButton:
		if not Ses.mouse_map == null and not Ses.curr_unit().is_busy():
			if event.is_action("chara_action"):
				act().on_mouse_chara_action( event.position, event.is_pressed() )
			elif event.is_action("chara_interact"):
				act().on_mouse_chara_interact( event.position, event.is_pressed() )


func _entering(_prev):
	me.require_UI(["Player_UI"])
	ally_count = me.get_tree().get_node_count_in_group("team_allies")
	me.update_player_info()
	my("Cam").disabled = true
	in_position = false


func _character_interaction(chara:Character) -> bool:
	# Only allow interactions if the character is idle.
	return chara.stt == "Idle"


func _character_actions_finished():
	ally_count -= 1
	if ally_count == 0:
		me.prev_state()


func _action_selected(action_state:String):
	super(action_state)
	act().on_being_selected()

func _mouse_on_character(chara:Character):
	## If a character has the mouse enter it.
	act().on_mouse_entered_character(chara)

func _not_mouse_on_character(last_chara:Character):
	## If the mouse leaves a character.
	act().on_mouse_exited_character(last_chara)
