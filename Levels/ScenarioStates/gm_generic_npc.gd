extends TacticsState

## This state manages what happens at the end and start of turns for Computer Controlled Characters (CCChar).

const AUTO_NPC_DECISION = false ## Automatically make character perform decision after selecting it.

var in_position : bool = true
var chara_pool : Array[Character]
var acting_chara : Character


func _entering(_prev):
	my("UI/Enemy_UI").show_visualization_ruler(not AUTO_NPC_DECISION)
	me.require_UI(["Enemy_UI"])
	my("Cam").disabled = false
	
	for chara in me.get_tree().get_nodes_in_group("team_hostile"):
		chara_pool.append(chara)
	chara_pool.sort_custom(Ses.unit_sort_algo)
	
	select_character()


func _proc(delta):
	# Move camera to focus on the acting character.
	if not (in_position or acting_chara == null):
		var Cam : Node3D = my("Cam")
		var cam_tgt = Vector3(acting_chara.position.x, Cam.position.y, acting_chara.position.z)
		Cam.position = Cam.position.move_toward(cam_tgt, delta * Cam.speed)
		if Cam.position.is_equal_approx(cam_tgt):
			in_position = true

func select_character():
	acting_chara = chara_pool.pop_back()
	var limits = acting_chara.consider_decisions()
	
	if not AUTO_NPC_DECISION:
		my("UI/Enemy_UI").update_visualization_ruler(limits)
		
		for decision in acting_chara.considerations:
			var destination = decision.move_traject.back()
			var score = acting_chara.robot.decision_score(decision)
			var color = Color.GREEN
			if score >= 0 and limits.y > 0:
				var color_weight = remap( score, 0, limits.y, 0, 1 )
				color = color.lerp(Color.BLUE, color_weight)
			elif limits.x < 0:
				var color_weight = remap( score, limits.x, 0, 1, 0 )
				color = color.lerp(Color.RED, color_weight)
			Ses.mission_scene.plot_on_grid([destination], color)
	
	# Show center of enemy squad
	Ses.mission_scene.plot_on_grid([acting_chara.avrg_enemy_coord], Color.WEB_PURPLE)
	
	#in_position = false
	if AUTO_NPC_DECISION:
		perform_decision()

## Make sure it's safe to perform a decision if called upon manually.
func manual_perform_decision():
	if not acting_chara.is_busy() and not AUTO_NPC_DECISION:
		perform_decision()

func perform_decision():
	var decision : CharacterAI.decision = acting_chara.robot.choose_decision(acting_chara.considerations)
	acting_chara.set_state("Walk", decision.move_traject.back())
	while acting_chara.is_busy():
		await acting_chara.state_changed
	acting_chara.set_state(decision.action_pick, decision.action_arg)
	while acting_chara.is_busy():
		await acting_chara.state_changed
	
	if chara_pool.is_empty():
		me.prev_state()
	else:
		select_character()
