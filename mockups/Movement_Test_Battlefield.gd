extends Node3D

var selected_unit : int = 0 : set = get_curr_unit


func get_curr_unit(select:int=-1) -> Character:
	if select >= 0:
		selected_unit = select
	if is_node_ready():
		var unit = $Units.get_child(selected_unit)
		%focus_name.text = unit.name
		%focus_name.set("theme_override_colors/font_color", unit.get_meta("color"))
		return unit
	else:
		return null


func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			#WARNING: Camera3D rotation (not any parent gimbal node) will break raycasting
			MOUSE_BUTTON_RIGHT:  # Move Selected Unit
				%Pick_Ray.target_position = %Cam.get_click_direction(event.position) * 1000
				%Pick_Ray.collision_mask = Ses.phys_layer.Terrain
				%Pick_Ray.force_raycast_update()
				if %Pick_Ray.is_colliding():
					get_curr_unit().move_to( %Pick_Ray.get_collision_point() )
			#MOUSE_BUTTON_LEFT:
				#pass
	
	if event.is_action_released("next_unit"):
		get_curr_unit(wrapi(selected_unit+1, 0, $Units.get_child_count())) 
	elif event.is_action_released("prev_unit"):
		get_curr_unit(wrapi(selected_unit-1, 0, $Units.get_child_count())) 
	
	if event is InputEventKey and event.is_released():

		match event.keycode:
			# Ability selection
			KEY_1:
				get_curr_unit().main_weapon()
			KEY_2:
				get_curr_unit().sec_weapon()
			KEY_3:
				get_curr_unit().overwatch()
			KEY_4:
				get_curr_unit().low_profile()
			KEY_5:
				get_curr_unit().deployable()
			KEY_6:
				get_curr_unit().ability(0)
			KEY_7:
				get_curr_unit().ability(1)
			KEY_8:
				get_curr_unit().ability(2)
			KEY_9:
				get_curr_unit().ability(3)


func draw_grid_range(_tile_radius:int, _color:Color = Color.CADET_BLUE):
	pass
