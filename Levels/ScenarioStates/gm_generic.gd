extends TacticsState


func _entering(prev):
	# Set up the game rules to the start, then let player control the characters.
	
	if prev == null:
		
		# It's the start of a new game.
		Ses.rounds = 0
		Ses.hostile_count = me.get_tree().get_node_count_in_group("team_hostile")
		
		# Make all characters invisible due fog-of-war
		for chara in me.get_tree().get_nodes_in_group("belligerents"):
			chara.statuses.append("Conceal_Bonus")
			
	# Make sure the correct UI is displaying.
	me.require_UI(["Sidebar"])
	my("Cam").disabled = true
	
	await me.get_tree().create_timer(0.6).timeout
	if prev != null and prev.name == "gm_generic_player":
		me.next_state("gm_generic_npc")
	else:
		me.next_state("gm_generic_player")
		
	
func _exiting(next):
	if next.name == "gm_generic_player":
		me.get_tree().call_group("tactics_each_round", "_new_round")
