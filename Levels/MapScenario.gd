extends Node
class_name MapScenario

## The base State Machine manager for directing maps.
const gridcell_texture = preload("res://Assets/Textures/grid_tile.png")

@export var default_zone_name : String = "Nowhere"

const MAX_STACK = 256  ## How many states to keep in history.
var stt : StringName  ## Current state
var stk : Array[StringName]  ## Stack of state history
var indx : int  ## The index of the top of the stack
var states : Dictionary  ## Set of available states, StringName: Script instance

@onready var mapfloor := Plane(Vector3.UP)
var hovered_character : Character

func _ready():
	Ses.mission_scene = self
	
	var n = 0
	for each : Character in Ses.get_belligerents(true, true):
		# Give a unique number to all characters, to make it reliable to cycle between them.
		each.ses_id = n
		Ses.last_ses_id = n
		n += 1
	Ses.selected_unit = 0
	update_player_info()
	
	# Populate the stack with a fixed number of elements
	stk.resize(MAX_STACK)
	# Populate the dictionary of states.
	for each in DirAccess.get_files_at("res://Levels/ScenarioStates/"):
		if each.get_extension() == "uid":
			continue
		var script_name : StringName = each.get_basename()
		states[script_name] = load("res://Levels/ScenarioStates/" + each).new()
		states[script_name].me = self
		states[script_name].name = script_name
	
	# Initate the first state.
	stt = Ses.game_mode
	states[stt]._entering(null)

#region Managing the Finite State Machine
func curr_state() -> TacticsState:
	return states[stt]

func next_state(state:StringName):
	if not state in states:
		print_rich("[color=yellow][bgcolor=black][b]FINITE STATE MACHINE[/b] next_state() not found :: "+ state +"[/bgcolor][/color]")
		push_error("Finite State Machine: attempting to switch to illegal state: ", state)
		return
	indx = indx + 1 % MAX_STACK
	stk[indx] = stt  # Store former current state in stack.
	stt = state  # next current state
	states[stk[indx]]._exiting(states[stt])
	states[stt]._entering(states[stk[indx]])
	
func prev_state():
	if stk[indx] == null:
		# If the history stack element is empty
		var msg = "The [b]Finite State Machine Stack[/b] attempted entering an [b]invalid state[/b] reference!"
		print_rich("[img=32]res://misc/textures/trollface.png[/img][bgcolor=red][color=white]",msg,"[/color][/bgcolor]")
		return
	else:
		states[stt]._exiting(states[stk[indx]])
		states[stk[indx]]._entering(states[stt])
		stt = stk[indx]
		indx = indx - 1 % MAX_STACK

func require_UI(names:Array[String]):
	## Each time a state is changed, it may specify which UI it's indended to be shown. All other UIs are hidden.
	for each in $UI.elements:
		each = $UI.get_node(each)
		if each.name in names:
			each.show()
		else:
			each.hide()
#endregion

#region Methods delegated by the Finite State Machine
func _process(delta):
	curr_state()._proc(delta)
func _physics_process(delta):
	curr_state()._phys_proc(delta)
func _input(event):
	if event.is_action_released("ui_cancel"):
		get_tree().call_group("when_paused", "_on_game_paused")
	else:
		
		if event is InputEventMouseMotion:
			var Cam : Camera3D = get_viewport().get_camera_3d()

			$Ray.position = Cam.project_ray_origin(event.position)
			$Ray.target_position = Cam.project_ray_normal(event.position) * 100000
			$Ray.force_raycast_update()
			if $Ray.is_colliding():
				var collider = $Ray.get_collider()
				if collider is Character and not hovered_character == collider:
					hovered_character = collider
					curr_state()._mouse_on_character(collider)
				elif not hovered_character == null:
					curr_state()._not_mouse_on_character(hovered_character)
					hovered_character = null
				var grid = collider.get_meta("parent_tacmap", "")
				if not grid.is_empty():
					grid = get_node(grid)
					Ses.mouse_map = grid
					mapfloor.d = grid.position.y
					var grid_offset = Vector3(grid.position.x, 0, grid.position.z)  # Accounting for displacements of the TacMap
					var cell_coord = mapfloor.intersects_ray(Cam.project_ray_origin(event.position) - grid_offset, Cam.project_ray_normal(event.position))
					if not cell_coord == null:
						cell_coord = Vector3i(cell_coord.snapped(Vector3.ONE))
						Ses.mouse_cell = Vector2i(cell_coord.x, cell_coord.z)
		
		curr_state()._input_event(event)
func _unhandled_input(event):
	curr_state()._unhandled_event(event)
func _on_character_action_select(action_state:String):
	curr_state()._action_selected(action_state)
func character_interaction(chara:Character) -> bool:
	return curr_state()._character_interaction(chara)
func character_actions_ended():
	curr_state()._character_actions_finished()
#endregion

#region Character Management
func update_player_info():
	_update_player_info()
func _update_player_info():
	## When something changes about the characters, this updates the UI.
	# This function is intended to be overridden depending on the available UI.
	pass

func add_character(_who:Character, _team:String):
	## Adds a character to a given team
	pass
func remove_character(_who:String):
	## Removes a character from the scene tree and returns it
	pass
func replace_character(_from:String, _to:Character):
	## Removes a character to place another one in its place
	pass
func switch_team(_who:String, _team:String):
	## Removes character from one team, and adds it to another
	pass

func _on_game_paused():
	pass
#endregion

#region Drawing gizmos on the grid

func clear_plots():
	for each in $Gizmos.get_children():
		each.queue_free()

func make_tile_gizmo(cell:Vector2i):
	var gizmo = Sprite3D.new()
	gizmo.position = Vector3(cell.x, 0.1, cell.y)  #TODO: Account for TacMap height.
	gizmo.texture = gridcell_texture
	gizmo.pixel_size = 1.0 / gridcell_texture.get_width()  #NOTE Careful to no do intenger division here!
	gizmo.axis = Vector3.AXIS_Y
	gizmo.no_depth_test = true
	return gizmo

func plot_on_grid(plot_path: Array[Vector2i], col:= Color.INDIAN_RED):
	for coord in plot_path:
		var tile = make_tile_gizmo(coord)
		if Ses.mouse_map is TacMap:
			tile.position += Ses.mouse_map.position
		tile.modulate = col
		$Gizmos.add_child(tile)

#endregion
