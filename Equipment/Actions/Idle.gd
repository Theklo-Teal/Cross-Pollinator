extends CharacterAction

func setup():
	slot = Character.K.OTHER
	title = "Idle"
	description = "Waiting for orders."

func entering(_arg=null):
	if me.stamina <= 0:
		Ses.mission_scene.character_actions_ended()
	
	# Ensure the character will be aligned to the grid.
	me.position.x = snapped(me.position.x, 1)
	me.position.z = snapped(me.position.z, 1)
	
	# Choose animation according to stance.
	match me.stance:
		me.STANCE.LOWER:
			my("%AnimationPlayer").play("Crouch")
		_:
			my("%AnimationPlayer").play("Idle")
	
	# Check if characters are revealed from concealement.
	for tgt in me.get_tree().get_nodes_in_group("belligerents"):
		if not tgt.is_in_group(me.team):
			tgt.statuses.erase("Conceal_Bonus")
	
	# Face away from cover
	var best_cover : Vector2i
	var best_kind := TacMap.TILE.PASS
	var dir = -me.basis.z
	dir = Math.cardinal_direction(Vector2i(dir.x, dir.z))
	for tile : Vector2i in Math.adjacent_cells(me.get_grid_coord(), dir):
		var kind = me.get_grid().tile_info.get(tile, {"kind":TacMap.TILE.PASS}).kind
		if best_kind == TacMap.TILE.FULL:
			break
		elif best_kind == TacMap.TILE.HALF:
			if kind == TacMap.TILE.FULL:
				best_cover = tile
				best_kind = kind
		else:
			best_cover = tile
			best_kind = kind
	me.look_at(Vector3(best_cover.x, 0, best_cover.y))
	
	#WARNING: This only works with ethan_lennox. We need a standard template for characters.
	if me.name == "ethan_lennox":
		my("%Cover_Indicator").visible = best_kind == TacMap.TILE.FULL

func exiting():
	#WARNING: This only works with ethan_lennox. We need a standard template for characters.
	if me.name == "ethan_lennox":
		my("%Cover_Indicator").visible = false

func select_next():
	# The player wants to select the next character
	Ses.curr_unit(Ses.selected_unit + 1)
	Ses.mission_scene.update_player_info()

func select_prev():
	# The player wants to select the previous character
	Ses.curr_unit(Ses.selected_unit - 1)
	Ses.mission_scene.update_player_info()

func is_busy():
	return false

func get_target_characters(from:Character=null, _occluded:bool=false) -> Array[Character]:
	## Which characters in the game session you can target with this action.
	if from == null:
		from = me
	var valid_targets : Array[Character]
	for tgt in from.get_tree().get_nodes_in_group("team_allies"):
		valid_targets.append(tgt)
	return valid_targets
