extends RefCounted
class_name CharacterAI

## A class that's meant to be overriden to enable different behaviours depending on the character.

var me : Character

func _init(who:Character):
	me = who

var weapon_priority : Array[String]= [  # which weapons is this character more averse of? More priority to elements at the end of the array.
	"Chaingun",
	"Battle_Rifle",
	"Frag_Grenade",
]


func decision_score(which:decision):
	return which.move_score * 2 + which.action_score

## How to decide which decisions have priority?
func score_sort_method(a:decision, b:decision):
	return decision_score(a) > decision_score(b)

func choose_decision(decisions:Array[decision]) -> decision:
	# Sort all the potential decisions according to score
	decisions.sort_custom(score_sort_method)
	#NOTE By default we just pick the decision with the top score, but there might be various of the same score.
	#NOTE These could be selected at random, or you could even select at random from all decisions above a score threshold.
	#NOTE Alternative ways to select a decision grant less deterministic behaviour from characters.
	return decisions.front()


## Find grid coordinates which the character would want to move to.
## Returns the cell coordinate with the path to arrive there.
func find_movement_destinations() -> Dictionary:
	var obstacles : Array[Vector2i]
	var spots : Dictionary  # coord:Vector2i -> trajectory:Array[Vector2i]
	var tacmap : TacMap = me.get_grid()
	var max_range = me.max_steps()
	
	# What are all grid cells within this radius?
	for coord in Math.circle_on_grid(me.get_grid_coord(), max_range):
		# Which ones have an obstacle that can be used for cover?
		if tacmap.is_solid(coord):
			obstacles.append(coord)
	
	# Which cells are adjacent to that obstacle?
	for coord:Vector2i in TacMap.contour_shape(obstacles):
		# Reject cells which are invalid tiles or have other objects taking space.
		if tacmap.is_solid(coord) or tacmap.is_blocked(coord):
			continue
		
		# Reject cells for which the pathfinding can't reach a solution.
		var traject = tacmap.get_trajectory(me.get_grid_coord(), coord)
		if max_range < traject.size():
			continue
		
		spots[coord] = traject
	
	# Include the current character position as a possibility.
	spots[me.get_grid_coord()] = [me.get_grid_coord()]
	
	return spots

## What's the priority score for moving to a certain cell?
func movement_score(trajectory:Array[Vector2i]) -> float:
	var score : float = 0.0
	var tgt_cell = trajectory.back()
	
	# Penalty for having to spend stamina
	score -= me.walk_stamina_cost(trajectory.size())
	
	var enemies_in_sight : bool = false
	var cover_score : float = INF
	for chara : Character in me.get_tree().get_nodes_in_group("team_allies"):  #TODO figure out what is the enemy team instead of making assumptions.
		if not me.can_see(chara):
			continue
		enemies_in_sight = true
		
		# Bonus from avoiding exposure to enemy
		# Pick the worst case of cover score from all the characters.
		cover_score = min(cover_score, me.get_grid().cover_score(tgt_cell, chara.get_grid_coord()))
		
		#TODO Penalty for approaching enemy holding weapons according to aversion
		
		# Bonus from flanking the enemy
		#FIXME This makes the characters walk away from enemies as far as they can.
		#var enemy_dir = Vector2(chara.basis.z.x, chara.basis.z.z).normalized()  # Direction the enemy is facing
		#var my_dir = chara.get_grid_coord() - move_coord  # Direction of cell being tested towards enemy
		#move_score += max(enemy_dir.dot(my_dir) + 1, 0.9) * 0.3  # if my_dir is the same direction as enemy_dir, it means we are looking at the enemy's back. At a perpendicular, the dot product is zero, so bump it by one. Facing the enemy has a dot product of -1, bumping it up returns 0. We clamp amything lower than perpendicular to zero.
	
	if cover_score < INF:
		score += cover_score * 3
	
	# Find the average distance to enemies.
	if enemies_in_sight:
		var proxi_chara_avrg = me.get_grid().get_trajectory(me.get_grid_coord(), me.avrg_enemy_coord, me.max_steps()).size()
		var proxi_cell_avrg = me.get_grid().get_trajectory(tgt_cell, me.avrg_enemy_coord).size()
		var proxi_score : float = -(proxi_cell_avrg - proxi_chara_avrg)
		score += proxi_score * 0.5
	
	return score

## What's the priority score for using an action at a given cell?
func action_score(action:String, cell:Vector2i) -> float:
	var act = Ses.actions[action]
	#TODO Check whether action can hit character
	#TODO Bonus for attacking characters with higher speed
	#TODO Bonus for attacking characters with higher health
	#TODO Check how much damage the action causes to character
	return 0.0

## A capsule about anything about a decision.
class decision:
	var move_traject : Array[Vector2i]
	var action_pick : String
	var action_arg : Vector2i
	var move_score : float = 0.0
	var action_score : float = 0.0
	
	func _init(me:Character, move_trajectory:Array[Vector2i], act:String) -> void:
		var move_coord = move_trajectory.back()
		
		move_traject = move_trajectory
		move_score = me.robot.movement_score(move_trajectory)
		
		action_pick = act
		action_score = me.robot.action_score(act, move_coord)
