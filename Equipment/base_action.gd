extends RefCounted
class_name CharacterAction

## Template of Finite State Machine state for characters.

var me : Character
func my(path:NodePath) -> Node:
	return me.get_node(path)


var icon_texture : Texture2D = preload("res://Assets/Textures/action_atlas_square.tres")
var slot : Character.K = Character.K.OTHER
var title : String = "Empty Slot"  # The name shown to the player for selecting this action.
var description : String = "The Unit isn't equiped in this slot."
var init_ammo : int  ## Ammo when the session starts. 0 = infinite, >0 = limited uses, <0 = Cooldown turns
var target  ## Point of focus for the character (for example the destination when walking or enemy being aimed at)
var ammo : int  ## Current ammo
var used : bool  ## Was this action already activated in a round?

func _init(manager:Character=null):
	#NOTE only rely on NULL if you only want info about the action and don't expect it to perform logic.
	me = manager
	set_icon()
	setup()

func set_icon():
	icon_texture.region = Rect2( Vector2.ZERO,  Vector2(64, 64) )

func setup():
	pass


func get_bonus_actions() -> Array[String]:
	# If a certain action grants the player other actions as perks, return what they are here.
	#NOTE This returns filenames (without extension) for the action script.
	return []

func get_bonus_perks() -> Array[String]:
	# If a certain action grants actual perks or status effects to the character, return what they are here.
	return []


## Which characters in the game session you can target with this action.
## Set «occluded» to true, if you only care about characters in line of sight and not hidden by stats.
func get_target_characters(from:Character=null, occluded:bool=false) -> Array[Character]:
	if from == null:
		from = me
	var valid_targets : Array[Character] = []
	if occluded and "Blinded_Ailment" in from.statuses:  # No point iterating tests if a character can't see anything.
		return valid_targets
	
	for tgt : Character in target_characters(me.team):
		if occluded and not from.can_see(tgt):  # Filter characters that are occluded
			continue
		valid_targets.append(tgt)
	return valid_targets

## Override this to define what «get_target_characters()» discriminates.
func target_characters(of_team:String):
	var targets : Array[Character] = []
	for faction in Ses.get_enemies(of_team):
		var members : Array[Character]
		members.assign(me.get_tree().get_nodes_in_group(faction))
		targets += members
	return targets

## The player wants to select the next character
func select_next():
	Ses.mission_scene.get_node("%Sidebar").select_next()
	#me.look_at(Vector3(dest.x, 0, dest.y))

## The player wants to select the previous character
func select_prev():
	Ses.mission_scene.get_node("%Sidebar").select_prev()

func on_being_selected():
	## What to do if the player selects this action (not when the character is running it as their current state).
	pass

func on_mouse_motion(_screen_pos:Vector2):
	## What happens when the player has selected this action and moved the mouse over the TacMap.
	## This is not for when the action is the current Character FSM state.
	pass

func on_mouse_chara_action(_screen_pos:Vector2, _pressed:=false):
	## What happens when the player has selected this action and clicked the «chara_action» button.
	## This is not for when the action is the current Character FSM state.
	## With «pressed» you know if the mouse button was pressed or released.
	pass

func on_mouse_chara_interact(_screen_pos:Vector2, _pressed:=false):
	## What happens when the player has selected this action and clicked the «chara_interact» button.
	## This is not for when the action is the current Character FSM state.
	## With «pressed» you know if the mouse button was pressed or released.
	pass

func on_event_key(_event:InputEventKey):
	## What happens when the player has selected this action and pressed on the keyboard.
	## This is not for when the action is the current Character FSM state.
	pass

func on_mouse_entered_character(_chara:Character):
	pass
	
func on_mouse_exited_character(_last_chara:Character):
	pass

func entering(_argument=null):
	#NOTE if needing to change state here, you need to use call_deferred()
	#NOTE By default quit state, unless overridden to do something. It avoids that actions that aren't properly defined break the characters.
	me.call_deferred("set_state", "Idle")

func exiting():
	pass

func proceed(_delta:float):
	pass

func is_lazy():
	return true

func is_busy():
	return true

func is_flying():
	return false

func get_grid_blocks() -> Array[Vector2i]:
	return [me.get_grid_coord(), ]
