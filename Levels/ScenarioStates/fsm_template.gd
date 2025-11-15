extends RefCounted
class_name TacticsState

var me : MapScenario  ## The FSM manager script
var name : StringName  ## My own file name (except file extension) Set automatically by the FSM manager

func my(node_path:String) -> Node:
	## Get's a node in the level scene.
	return me.get_node(node_path)

func act() -> CharacterAction:
	## This returns the action the player selected to potentially play next.
	## To get the current character action, which is the current state in the Characters state machine, just call functions on the Character itself.
	var skill_name = my("%Character").get_selected_action()
	return Ses.curr_unit().states[skill_name]


func _proc(_delta:float):
	## Actions on each frame
	pass

func _phys_proc(_delta:float):
	## Actions on each physics frame
	pass
	
func _input_event(_event:InputEvent):
	## Actions on any input
	pass

func _unhandled_event(_event:InputEvent):
	## Actions on unhandled input
	pass

func _entering(_prev_state:TacticsState):
	## Actions when switching to this state
	pass

func _exiting(_next_state:TacticsState):
	## Actions when switching to another state
	pass

func _character_interaction(_chara:Character) -> bool:
	## An interactable trigger has been queried, so how should the state machine adjust?
	## Return false to disallow interaction. Return true once ready to allow interaction.
	return false

func _action_selected(_action_name:String):
	# Clear any gizmos the Character Actions might have requested to write before
	me.clear_plots()

func _character_actions_finished():
	## When a character runs out of actions it can do, progressing towards end of turn.
	pass

func _mouse_on_character(_chara:Character):
	## If a character has the mouse enter it.
	pass

func _not_mouse_on_character(_last_chara:Character):
	## If the mouse leaves a character.
	pass
