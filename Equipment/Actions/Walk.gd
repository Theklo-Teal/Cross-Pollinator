extends CharacterAction

const SPEED_SCALE = 0.5

var waypoints : Array[Vector2i]
var next_tile : Vector2
var tiles_crossed : int

func setup():
	slot = Character.K.OTHER
	title = "Move"
	description = "Walk towards selected destination."

func get_target_characters(from:Character=null, _occluded:bool=false) -> Array[Character]:
	## Which characters in the game session you can target with this action.
	var valid_targets : Array[Character]
	for tgt in from.get_tree().get_nodes_in_group("team_allies"):
		valid_targets.append(tgt)
	return valid_targets

func entering(argument=null):
	if argument == null:
		target = me.get_grid_coord()
	else:
		target = argument
	
	Ses.mission_scene.clear_plots()
	tiles_crossed = 0
	
	waypoints = Ses.mouse_map.get_trajectory(me.get_grid_coord(), target, me.max_steps())
	if waypoints.is_empty():
		next_tile = target
	else:
		waypoints.reverse()
		next_tile = Vector2(waypoints.pop_back())
		me.look_at(Vector3(next_tile.x, 0, next_tile.y), Vector3.UP, true)
		my("%AnimationPlayer").play("Walk")

func exiting():
	me.stamina -= ceili(float(tiles_crossed) / me.speed)
	me.has_walked = true
	Ses.mission_scene.update_player_info()

func proceed(delta:float):
	var curr_pos = Vector2(me.position.x, me.position.z)
	if next_tile.is_equal_approx(curr_pos):
		var next = waypoints.pop_back()
		if next == null:
			end_of_travel()
		else:
			me.look_at(Vector3(next.x, 0, next.y), Vector3.UP, true)
			next_tile = Vector2(next)
			tiles_crossed += 1
	
	var tgt = Vector3(next_tile.x, Ses.mouse_map.position.y, next_tile.y)
	me.position = me.position.move_toward(tgt, delta * SPEED_SCALE * (me.speed + 1))


func select_next():
	# The player wants to select the next character
	Ses.curr_unit(Ses.selected_unit + 1)
	Ses.mission_scene.update_player_info()

func select_prev():
	# The player wants to select the previous character
	Ses.curr_unit(Ses.selected_unit - 1)
	Ses.mission_scene.update_player_info()

func is_lazy():
	match me.stance:
		Character.STANCE.LOWER:
			return true
		Character.STANCE.RAISE:
			return false
		Character.STANCE.NOMIN:
			#TODO have some sort of determination based on character personality and health.
			return false

func get_grid_blocks() -> Array[Vector2i]:
	return [target, ]

func end_of_travel():
	me.set_state("Idle")


func on_mouse_motion(_screen_pos:Vector2):
	## Displays the possible paths for the character.
	## The length of a path depends on character speed.
	## New lengths are appended depending on character stamina.
	#NOTE In this particular action state, this function will still be called even while it is the current action, because the there is no way for the player to select "Idle", which would be the expected thing to do. No player selection of selection always means "Walk".
	if not (me.stt == "Walk" or me.has_walked):
		var color = Color.MEDIUM_BLUE
		var plot : Array[Vector2i] = Ses.mouse_map.get_trajectory(me.get_grid_coord(), Ses.mouse_cell)
		Ses.mission_scene.clear_plots()
		var segm_count := 0
		for segm in range(0, plot.size(), me.speed):
			if segm_count >= me.stamina:
				break
			Ses.mission_scene.plot_on_grid(plot.slice(segm, segm + me.speed), color)
			color = color.lightened(0.38)
			segm_count += 1


func on_mouse_chara_action(_screen_pos:Vector2, pressed:=false):
	#NOTE Given the issue with on_mouse_motion, why this function doesn't allow us to change character trajectory while walking is mystery, but I'm glad it works that way.
	if not (pressed or me.has_walked):
		var path : Array[Vector2i] = Ses.mouse_map.get_trajectory(me.get_grid_coord(), Ses.mouse_cell)
		if path.is_empty():
			return
		var destination = path[ min(me.stamina * me.speed, path.size() - 1 ) ]
		me.set_state("Walk", destination)
