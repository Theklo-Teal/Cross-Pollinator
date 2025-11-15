@tool
extends EditorPlugin

## A Node and editor panel to help generate 3D tile based game maps, namely turn-based tactical combat.
#TODO: enable undo/redo function.

var toolbox_dock : Control
var toolbox_button : Control
var Floor := Plane(Vector3.UP)

var map_node : TacMap  ## Currently selected Tactical Map node.
var cursor_pos : Vector2i  ## Which grid cell the cursor is hovering.
var last_bottom_panel : Control  ## Which panel to show if the user de-selects a TacMap node.

var cursor_start : Vector2i

func _enter_tree():
	toolbox_dock = preload("tac_map_toolbox.tscn").instantiate()
	toolbox_dock.plugin = self
	toolbox_button = add_control_to_bottom_panel(toolbox_dock, "Tactical Map")
	toolbox_button.hide()

func _exit_tree():
	remove_control_from_bottom_panel(toolbox_dock)
	toolbox_dock.queue_free()
	toolbox_button.queue_free()


func _handles(object):
	if object is TacMap:
		map_node = object
		object.set_disp_floor(object.display_floor)
		return true
	else:
		if not map_node == null:
			pass
			map_node.hide_gizmo()
		map_node = null
		return false

func _make_visible(visible):
	toolbox_button.visible = visible
	if visible:
		make_bottom_panel_item_visible(toolbox_dock)
	else:
		hide_bottom_panel()

func _forward_3d_gui_input(Cam : Camera3D, event : InputEvent):
	if map_node == null:
		var selected_node = get_editor_interface().get_selection().get_selected_nodes()[0]
		if selected_node is TacMap:
			map_node = selected_node
		else:
			return
	
	if event is InputEventMouseMotion:
		Floor.d = map_node.position.y  # Get plane at the same height as the TacMap
		var grid_offset = Vector3(map_node.position.x, 0,  map_node.position.z)  # Accounting for displacements of the TacMap
		var cell_coord = Floor.intersects_ray(Cam.project_ray_origin(event.position) - grid_offset, Cam.project_ray_normal(event.position))
		if cell_coord == null:
			return
		
		cell_coord = Vector3i(cell_coord.snapped(Vector3.ONE))
		cursor_pos = Vector2i(cell_coord.x, cell_coord.z)
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					cursor_start = cursor_pos
					return false
		elif event.is_released():
			var success := false
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					success = [paint_tool, flood_tool, transform_tool, picker_tool][toolbox_dock.get_edit_mode()].call()
				MOUSE_BUTTON_XBUTTON1:
					success = map_node.rotate_floor(cursor_pos)
				MOUSE_BUTTON_XBUTTON2:
					success = map_node.rotate_prop(cursor_pos)
			if success:
				update_overlays()
				return EditorPlugin.AFTER_GUI_INPUT_STOP


func parse_tile_library(filepath:String, context:String):
	var libr = filepath.substr(filepath.find(context))
	libr = libr.split("/")[1]
	return libr

func paint_tool():
	var success := false
	var ini = Vector2i( min(cursor_start.x, cursor_pos.x), min(cursor_start.y, cursor_pos.y) )
	var end = Vector2i( max(cursor_start.x, cursor_pos.x), max(cursor_start.y, cursor_pos.y) )
	var data = toolbox_dock.get_tile_content()
	for x in range(ini.x, end.x + 1):
		for y in range(ini.y, end.y + 1):
			var coord = Vector2i(x, y)
			var result = map_node.set_tile(coord, data)
			success = success or result
	return success

func flood_tool():
	print("The flood fill tool isn't implemented!")

func transform_tool():
	# Do nothing. Allow the usual editor functions to work.
	return false

func picker_tool():
	var data = map_node.get_info(cursor_pos)
	if not data == null:
		var options = {
			"kind" : data.kind,
			"floor_rotation" : data.floor_rotation,
			"prop_rotation" : data.prop_rotation,
			"floor_library" : parse_tile_library(data.floor.path, "Floors"),
			"prop_library" : parse_tile_library(data.prop, "Obstacles"),
			"floor" : data.floor.name,
			"prop" : data.prop.get_file().get_basename(),
		}
		map_node.floor_rot = data.floor_rotation
		map_node.prop_rot = data.prop_rotation
		toolbox_dock.set_tile_options(options)
	return (cursor_pos.x < map_node.reach.x and cursor_pos.y < map_node.reach.y)
