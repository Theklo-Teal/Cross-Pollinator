@icon("res://Characters/base_character.png")
extends Interactable
class_name Character

signal state_changed(previous_state:String)

## This class gathers all the character behaviours. It defines the current action being performed by finite state machine.
## This class' node should be a child of a TacMap node on which it navigates.

var ses_id : int  ## Unique number for when selecting characters.
var stt : String  ## Which node of the FSM is the character running?
var stance : STANCE
var states := {
	"Idle": preload("res://Equipment/Actions/Idle.gd").new(self),
	"Walk": preload("res://Equipment/Actions/Walk.gd").new(self),
	"Overwatch": preload("res://Equipment/Actions/Overwatch.gd").new(self),
	"Hunker_Down": preload("res://Equipment/Actions/Hunker_Down.gd").new(self),
}

enum SIZE{
	SMALL, ## Drone robots
	NOMIN,  ## Average man sized
	LARGE  ## Tanky characters
}

enum STANCE{
	NOMIN,  # Just standing up and loitering
	LOWER,  # Going extra careful and slower
	RAISE  # Being hyped and alert
}

enum K{
	OTHER,  ## It's a number selected action.
	PRIM,
	SECO,
	DEPL,
	RAISE,
	LOWER,
	ARMOR,  ## Exists to provide bonuses.
	RANK,
}

## Actions on the basic slots, selected with letter keys.
var added_actions : Dictionary = {
	K.PRIM : "",
	K.SECO : "",
	K.DEPL : "",
	K.RAISE : "Overwatch",
	K.LOWER : "Hunker_Down",
	K.ARMOR : "",
}

## Stuff that will be used if nothing is set. In the «states» dictionary, names mentioned here won't be removed.
var default_actions := {
	K.PRIM : "",
	K.SECO : "",
	K.DEPL : "",
	K.RAISE : "Overwatch",
	K.LOWER : "Hunker_Down",
	K.ARMOR : "",
}


@export var portrait : Texture
@export var unique_name := true  ## When multiple characters of the same name exist, this appends a number to their name.
@export var unit_size := SIZE.NOMIN
@export_enum("team_allies", "team_hostile", "team_friend", "team_aggro", "team_neutral") var team : String = "team_neutral"
@export var lore : CharacterLore

@export_group("Default Traits")
@export var max_health := 3
@export var max_stamina := 2  ## The amount of actions the character can perform per round.
@export var max_mental := 4  ## How resistant the character will panic, miss or fumble and horniness.
@export var speed := 5  ## How many tiles the character moves per stamina point.
@export var will := 10  ## resistance to changes in mental
@export var appeal := 10  ## effectiveness at changing mental on others

@export_group("Perks and Abilities")
@export var access_clearance : Array[String]  ## Character can only move to restricted areas with these names.
@export var base_perks : Array[String]  ## Character unique passives
@export var base_actions : Array[String]  ## Abilities selected with number keys.
@export var rank_actions : Array[String]  ## Special abilities unlocked depending on rank promotion.

# Starting character statuses can be fudged by the game mode, so here the game mode can choose what to add.
var robot : CharacterAI
var statuses : Array[String]  ## Ailmentes or Bonuses, which are added during gameplay and temporary.
var added_perks : Array[String]  ## Passives depending on equipment
var bonus_actions : Array[String]  ## Extra actions depending on equipment, selected with number keys.

# Current value of traits during the gameplay session.
var health : int
var stamina : int
var mental : int

var at_zone : String = "Somewhere"  ## What is the current section of the Tactical Grid is called?
var initial_location : Vector2i  ## What grid coordinate the character was when the round started.
var has_walked : bool  ## Characters can only walk once per turn. If they spend all the stamina walking, they won't be able to use weapons.

#region Basic Stuff
func _enter_tree():
	# When character is spawned
	position = position.snapped(Vector3.ONE)

func _ready() -> void:
	super()
	collision_layer = Ses.phys_layer["Character"]
	
	add_to_group(team)
	
	health = max_health
	stamina = max_stamina
	mental = max_mental
	
	stt = "Idle"
	states[stt].entering()
	
	# Different game modes have different goals, so the AI behaviour might differ.
	var AI_file = "res://Characters/Robots/"+Ses.game_mode+"/"+base_name()+".gd"
	if FileAccess.file_exists(AI_file):
		robot = load(AI_file).new(self)
	else:
		robot = load("res://Characters/Robots/CharacterAI.gd").new(self)
		
	if unique_name:
		name += "Ç" + str(hash(self))

func _new_round():
	initial_location = get_grid_coord()
	stamina = max_stamina
	has_walked = false

## The name of the characters might have an hash extension if there are multiple instances at the same time.
## This returns the actual name expected in character files.
func base_name() -> String:
	var suffix = name.find("Ç", 3)  # The "from" argument makes sure we won't get an empty string as result.
	if suffix >= 3:
		return name.left(suffix).capitalize()
	else:
		return name

## Formats the name to display in Constrol nodes.
func human_name() -> String:
	var suffix = name.find("Ç", 3)  # The "from" argument makes sure we won't get an empty string as result.
	if suffix >= 3:
		return name.left(suffix).capitalize()
	else:
		return name.capitalize()

func compute_bonuses(action:CharacterAction) -> Dictionary:
	## Given an action, return a list of bonuses as a dictionary.
	var output := {
		K.RAISE: null,
		K.LOWER: null,
		"actions": [],
		"perks": [],
	}
	for bonus_name in action.get_bonus_actions():
		if not bonus_name in output["actions"]:
			var bonus = Ses.actions[bonus_name].new(self)
			if bonus.slot == Character.K.OTHER:
				output["actions"].append(bonus_name)
			else:
				output[bonus.slot] = bonus_name
			compute_bonuses(bonus)
	for bonus_name in action.get_bonus_perks():
		if not bonus_name in output["perks"]:
			output["perks"].append(bonus_name)
	return output

#endregion

#region Perception
func can_see(unit:Character):
	## Is the "unit" in range and line of sight of this character?
	#NOTE This assumes both this character the "unit" are in the same TacMap.
	if "Blinded_Ailment" in statuses:
		return false
	if "Conceal_Bonus" in unit.statuses and not unit.is_in_group(team):
		return false
	
	var adjacent_cells := Math.adjacent_cells(get_grid_coord())
	var adjacent_obstacles : Array[Vector2i]
	for cell in adjacent_cells:
		if get_grid().is_solid(cell):
			adjacent_obstacles.append(cell)
	var peeking_spots = TacMap.contour_shape(adjacent_obstacles, adjacent_cells)  # Which coordinates are valid for the character to peek around cover.
	peeking_spots.append(get_grid_coord())  # Make the character also check direct line of sight, not only the peeking around obstacles.
	var peeking_failures : int = 0  # How many perspectives failed to connect to the target.
	for perspective in peeking_spots:
		var sight_line = Math.line_on_grid(perspective, unit.get_grid_coord())
		for cell in sight_line:
			if get_grid().is_solid(cell, false):
				peeking_failures += 1
				break  # Go check the next perspective
	return peeking_failures < peeking_spots.size() # Are there any lines of sight that connect to the target?

func cover_score(unit:Character) -> float:
	## How well protected is this character from hitscan fire from "unit"?
	return get_grid().cover_score(get_grid_coord(), unit.get_grid_coord())

#endregion

#region Navigation
func entered_zone(zone_name):
	# This is called by the Zones which are the ones detecting characters, rather than characters detecting them.
	at_zone = zone_name

func exited_zone(_zone_name):
	## For when leaving into a non-zoned area
	# This is called by the Zones which are the ones detecting characters, rather than characters detecting them.
	at_zone = ""

func max_steps_taken(steps:int) -> bool:
	## Has the character hit the limit of steps they are allowed to do?
	return steps >= max_steps()

func max_steps() -> int:
	## How many steps can the character take?
	return (speed+1) * stamina

func walk_stamina_cost(steps:int) -> int:
	## How much stamina will take to move over an amount of tiles.
	return floori(float(steps) / float(speed) + 1)
#endregion

#region Finite State Machine
func set_state(new_state:String, tgt_arg=null):
	#NOTE «new_state» is the filename of the script without file extension.
	var prev_state = stt
	states[prev_state].exiting()
	states[new_state].entering(tgt_arg)
	stt = new_state
	state_changed.emit(prev_state)

func ready_states(skills:Dictionary):
	## Make states for the FSM out of their references in a save file.
	## The save file is edited by the loadout menu.
	
	#TODO clear or set to default each added action
	#TODO account armour
	#TODO account base actions
	#FIXME This is very specific to player characters. Make it account NPCs
	
	bonus_actions.clear()
	added_perks.clear()
	var RAISE : String = default_actions[K.RAISE]
	var LOWER : String = default_actions[K.LOWER]
	
	var rank : int = 0
	for choice in skills.rank:
		if (rank * 2 + 1) > rank_actions.size(): # There aren't any more actions for the character's rank.
			break
		bonus_actions.append(rank_actions[rank * 2 + int(choice)])
		rank += 1
	
	for skill_name in skills.loadout:
		if skill_name in Ses.actions:
			var skill = Ses.actions[skill_name].new(self)
			states[skill_name] = skill
			added_actions[skill.slot] = skill_name
			var dict = compute_bonuses(skill)
			if dict[K.RAISE]:
				RAISE = dict[K.RAISE]
			if dict[K.LOWER]:
				LOWER = dict[K.LOWER]
			for each in dict.actions:
				if not each in bonus_actions:
					bonus_actions.append(each)
			for each in dict.perks:
				if not each in added_perks:
					added_perks.append(each)
	
	states[RAISE] = Ses.actions[RAISE].new(self)
	added_actions[K.RAISE] = RAISE
	states[LOWER] = Ses.actions[LOWER].new(self)
	added_actions[K.LOWER] = LOWER

	for skill_name in bonus_actions:
		if skill_name in Ses.actions:
			var skill = Ses.actions[skill_name].new(self)
			states[skill_name] = skill
		
func _process(delta: float) -> void:
	states[stt].proceed(delta)

func is_lazy() -> bool:
	##  Will this character avoid all types of obstacle?
	return states[stt].is_lazy()

func is_busy() -> bool:
	return states[stt].is_busy()

func is_flying() -> bool:
	##  Will this character cross different height Tac_Maps without needing a ladder?
	return states[stt].is_flying()

func get_grid_blocks() -> Array[Vector2i]:
	## Which coordinates on the TacMap does this character need to be blocked from passage of other characters?
	return states[stt].get_grid_blocks()
#endregion

#region CHARACTER AI
var assessed_enemies : Array[Character] # List of enemies that may be targeted
var avrg_enemy_coord := Vector2i.ZERO # Position of the center where detectable enemies are.
var considerations : Array[CharacterAI.decision]

## Compute which tiles make sense for the character to move towards
## Returns the lowest and highest score found.
func consider_decisions() -> Vector2:
	# Detect position of known enemies
	#NOTE We don't care to detect enemies at move destinations, so that we can allow for ambushes.
	var enemy_pos : Array[Vector2i]
	assessed_enemies.clear()
	if not "Blinded_Ailment" in statuses:
		for enemy_team in Ses.get_enemies(team):
			for chara : Character in get_tree().get_nodes_in_group(enemy_team):
				if can_see(chara):
					assessed_enemies.append(chara)
	
	if enemy_pos.is_empty():
		avrg_enemy_coord = get_grid_coord()
	else:
		avrg_enemy_coord = Vector2i(Math.centroid(enemy_pos).round())
	
	considerations.clear()
	
	# Create a potential decision for every valid cell to travel to.
	var movements = robot.find_movement_destinations()
	var min_score : float = 0.0
	var max_score : float = 0.0
	
	for coord in movements:
		var trajectory:Array[Vector2i] 
		trajectory.assign(movements[coord])
		for act in base_actions + added_actions.values() + bonus_actions:  # Check all the actions at each position.
			if act.is_empty():
				continue
			
			var action = Ses.actions[act].new(self)
			#action.get_target_characters() #TODO: this needs to be made smarter.
			#for chara : Character in me.assessed_enemies:
			
			var decision = robot.decision.new(self, trajectory, act)
			considerations.append( decision )
			min_score = min(min_score, robot.decision_score(decision))
			max_score = max(max_score, robot.decision_score(decision))
	
	return Vector2(min_score, max_score)

#endregion
