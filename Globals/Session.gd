extends Node

var paused := false

#region Basic Stuff
var phys_layer : Dictionary[String, int]
var perks : Dictionary[String, CharacterPerk]
var actions : Dictionary[String, GDScript]  # The scripts are uninitialized «CharacterAction»
var playdata := ConfigFile.new()

func _ready():
	#TODO select save file
	playdata.load("res://Savedata/"+"default.ini")
	
	for n in range(1, 33):
		var layer : String = ProjectSettings.get_setting("layer_names/3d_physics/layer_"+str(n))
		if not layer.is_empty():
			phys_layer[layer] = int(pow(2, n - 1))
	
	for each in DirAccess.get_files_at("res://Equipment/Perks/"):
		if each.get_extension() == "tres":
			var status = load("res://Equipment/Perks/"+each)
			perks[each.get_basename()] = status
	
	for each in DirAccess.get_files_at("res://Equipment/Actions/"):
		if each.get_extension() == "gd":
			var act = load("res://Equipment/Actions/"+each)
			actions[each.get_basename()] = act

func save_playdata():
	#TODO select save file
	playdata.save("res://Savedata/"+"default.ini")

#endregion

#region Actions
func update_action_ui(action_name:String, node:TextureButton):
	## Changes a TextureButton node to have the correct appearance and text for a given character action.
	var act : CharacterAction = actions.get(action_name, CharacterAction).new()
	node.tooltip_text = act.title
	var n : int = 0
	for each in ["normal", "hover", "pressed", "disabled"]:
		var propert = "texture_"+each
		var icon = act.icon_texture.duplicate()
		icon.region.position.x = n * icon.region.size.x
		node.set(propert, icon)
		n += 1

func new_action_ui(action_name:String) -> TextureButton:
	## Provides a TextureButton node for use with a character action.
	var node = TextureButton.new()
	update_action_ui(action_name, node)
	return node
#endregion

#region Perks
func update_perk_ui(perk_name:String, node:TextureRect, size:int=32):
	var perk = perks[perk_name]
	
	node.set_script(load("res://UI_Elements/perk_icon.gd"))
	node.custom_minimum_size = Vector2(size, size)
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.mouse_default_cursor_shape = Control.CURSOR_HELP
	node.tooltip_text = "[b]"+perk.title+"[/b]\n[center]"+perk.description+"[/center]"
	node.texture = perk.atlas.duplicate()

func new_perk_ui(perk_name:String) -> TextureRect:
	var icon := TextureRect.new()
	update_perk_ui(perk_name, icon)
	return icon
#endregion

#region Strategy Tactics Gameplay variables
var game_mode = "gm_generic"  #TODO game mode selection
var mission_dir = "res://Levels/Tactics/tactics_test.tscn"  #TODO mission selection
var mission_scene : MapScenario  # Current scene being played on.
var start_team : Array[Character]  # Which characters and their loadouts will participate in the next tactics session?
var rounds : int = 0   # How many rounds have gone.
var hostile_count : int = 0  # How many character the player has to deal with
var last_ses_id : int = 0  # The highest Character.ses_id given in a session.
var selected_unit : int = 0  # Selected Player Controlled character.

var mouse_map : TacMap  # Which battle grid is the mouse cursor over.
var mouse_cell : Vector2i  # Which coordinante on the battle grid is the mouse cursor over.

func unit_sort_algo(a,b):
	return a.ses_id < b.ses_id

func curr_unit(sel:int = -1) -> Character:
	## Get the currently selected player character. Can also set active character, if argument is given.
	var allies = get_tree().get_nodes_in_group("team_allies")
	if sel >= 0:
		selected_unit = wrapi(sel, 0, allies.size())
	allies.sort_custom(unit_sort_algo)
	return allies[selected_unit]

## Get list of teams a certain team wants to attack.
func get_enemies(team:String) -> Array[String]:
	const reputation = {
		"team_allies": ["team_hostile", ],
		"team_hostile": ["team_allies", ],
		"team_neutral": [ ],
		"team_friend": ["team_hostile", "team_aggro", ],
		"team_aggro": ["team_hostile", "team_allies", ],
		}
	var ans : Array[String] = []
	ans.assign(reputation[team])
	return ans

func get_belligerents(include_minions:=false, include_neutral:=false) -> Array[Character]:
	var answer : Array = []
	answer += get_tree().get_nodes_in_group("team_allies")
	answer += get_tree().get_nodes_in_group("team_aggro")
	if include_minions:
		answer += get_tree().get_nodes_in_group("team_friend")
		answer += get_tree().get_nodes_in_group("team_hostile")
	if include_neutral:
		answer += get_tree().get_nodes_in_group("team_neutral")
	
	var output : Array[Character]
	for each : Character in answer:
		output.append(each)
	return output
#endregion
