@tool
@icon("tac_map.png")
extends TacMap

#WARNING FIXME If the assets that are referenced in the TacMap are changed, then stuff breaks LOL

func _enter_tree():
	## Overrides the base TacMap function. This is hacky, but don't delete it,
	return


const gridcell_texture : Texture = preload("res://Assets/Textures/grid_tile.png")
const color_code = [
	Color.FLORAL_WHITE,
	Color.DARK_ORANGE,
	Color.INDIAN_RED,
	Color.MEDIUM_AQUAMARINE
]

var regenerated : bool = false  # Bypasses functions of setters until the map has been reconstructed after instancing.
var floor_rot : int  # Number from 0 to 4 (inclusive)
var prop_rot : int  # Number from 0 to 4 (inclusive)


@export var display_floor : bool : set = set_disp_floor
func set_disp_floor(val:bool):
	if not Engine.is_editor_hint():
		val = true
	display_floor = val
	if not is_node_ready():
		return
	if val:
		hide_gizmo()
	else:
		show_gizmo()

@export var clear : bool : set = set_clear
func set_clear(_val:bool):
	if not is_node_ready() or not Engine.is_editor_hint():
		return
	#NOTE: Theoretically this could be performed by just doing «reach = Vector(1,1)», but it needs to be more resilient to bad programming on other functions.
	for coord in tile_at:  # Doing the thing properly, for well behaved tiles
		rem_tile(coord)
	# Doing a bit overkill in case bad tiles are accumulating.
	tile_at.clear()
	for each in %gizmoed.get_children() + %floored.get_children() + %proped.get_children():
		each.queue_free()
	# Clear asset lists
	prop_list.clear()
	floor_list.clear()
	# Restore the tile that always must be present.
	reach = Vector2i.ONE

@export var reach := Vector2i(1,1) : set = set_reach
func set_reach(val:Vector2i):
	
	var old : Vector2i
	old.x = max(reach.x, 1)
	old.y = max(reach.y, 1)
	val.x = max(val.x, 1)
	val.y = max(val.y, 1)
	reach = val
	
	%Collider.shape.size = Vector3(float(val.x) - 1, 0.2, float(val.y) - 1)
	%Collider.get_parent().position = Vector3(val.x * 0.5 - 0.5, 0.1, val.y * 0.5 - 0.5)
	
	if not regenerated:
		return
	
	var union : Vector2i  # How far in the grid do we need to iterate, in other words the union of the old grid with a new one.
	union.x = max(val.x, old.x)
	union.y = max(val.y, old.y)
	
	#NOTE: Is there a way so we don't have to iterate over all the tiles every time?
	for x in range(union.x + 1):
		for y in range(union.y + 1):
			var coord = Vector2i(x,y)  # Current cell being checked
			if x >= val.x or y >= val.y:  # Is this cell outside the target grid? Then we need to shrink the old grid.
				rem_tile(coord)
			elif x >= old.x or y >= old.y:  # Otherwise we are expanding the grid.
				rst_tile(coord)
			else:  # This cell persists.
				continue

@export_storage var prop_list : Array[String]  ## File paths to scenes to be loaded.
@export_storage var floor_list : Dictionary  ## File paths, coordinates and any other data required to procedurally generate floor objects.
@export_storage var tile_info : Dictionary  ## props and floors are stored as indexes of prop/floor_list indexes. 
var tile_at : Dictionary  ## Vector2i coordinate of cell : tile data Dictionary
var navgrid_strict : AStarGrid2D  ## the navgrid only accounting terrain obstacles. Only accounts full obstacles.
var navgrid_all : AStarGrid2D  ## the navgrid only accounting terrain obstacles. Accounts all obstacles.

func duplicate_navigation(grid:AStarGrid2D) -> AStarGrid2D:
	var dupe = AStarGrid2D.new()
	dupe.default_compute_heuristic = grid.default_compute_heuristic
	dupe.default_estimate_heuristic = grid.default_estimate_heuristic
	dupe.diagonal_mode = grid.diagonal_mode
	dupe.jumping_enabled = grid.jumping_enabled
	dupe.region = grid.region
	dupe.update()
	
	for x in dupe.region.size.x:
		for y in dupe.region.size.y:
			var coord = Vector2i(x,y)
			dupe.set_point_solid(coord, grid.is_point_solid(coord))
			dupe.set_point_weight_scale(coord, grid.get_point_weight_scale(coord))
			
	return dupe

func _ready():
	%Collider.get_parent().set_meta("parent_tacmap", get_path())
	
	# Remove info for tiles outside the grid. (Because shifting the map on the grid preserves data)
	for coord in tile_info:
		if coord.x > reach.x or coord.y > reach.y:
			tile_info.erase(coord)
	
	#Regenerating the map
	for x in range(reach.x):
		for y in range(reach.y):
			var cell = Vector2i(x,y)
			gen_tile(cell)
	
	#TODO: delete prop_list and floor_list entries that weren't used. Requires re-indexing existing tiles.
	
	make_navgrids()
	regenerated = true
	call_deferred("set_disp_floor", display_floor)


## How well protected is a character from hitscan fire of a character at "target"?
func cover_score(from:Vector2i, target:Vector2i) -> float:
	# We only care about the 3 tiles adjacent to this character which are towards the "target", making a quadrant.
	var score : float = 0  # Higher score means better protection.
	var dir = Math.cardinal_direction(target - from)
	var cells = Math.adjacent_cells(from, dir)  # Remember we only care about a quadrant towards the enemy, so we'll only select three of the cells later.
	for n in [-1, 1, 0]:  # get_adjacent_tiles has the first tile as the one closest to the enemy, but we will want the one before that and the one after that.
		var obstacle = tile_info.get(cells[n], {"kind": TILE.PASS}).kind
		var val : float
		
		match obstacle:
			TILE.PASS, TILE.LADD:
				val += 0
			TILE.HALF:
				val += 0.25
			TILE.FULL:
				val += 0.5
				
		if (dir + n) % 2 == 0:  # Obstacle at cross cardinal
			score += val
		else:  # Obstacle at diagonal cardinal
			score += 0.5 * val
	return score


func get_info(cell:Vector2i):
	if cell in tile_info:
		var data = tile_info[cell].duplicate(true)
		data.floor = floor_list[data.floor]
		data.prop = prop_list[data.prop]
		return data
	else:
		return null


func show_gizmo():
	%gizmoed.show()
	%floored.hide()
func hide_gizmo():
	%gizmoed.hide()
	%floored.show()


#region Manage tiles
func rem_tile(cell:Vector2i):
	## Eliminate visual entities for tile and clear any info on it.
	tile_info.erase(cell)
	if cell in tile_at:
		if not tile_at[cell].get("gizmo", null) == null:
			tile_at[cell].gizmo.queue_free()
		if not tile_at[cell].get("floor", null) == null:
			tile_at[cell].floor.queue_free()
		if not tile_at[cell].get("prop", null) == null:
			tile_at[cell].prop.queue_free()
		tile_at.erase(cell)

func rst_tile(cell:Vector2i, delete_info := false):
	## Make an empty tile anew, to defaults objects, eliminating regeneration data optionally.
	if cell in tile_at:
		if not tile_at[cell].get("gizmo", null) == null:
			tile_at[cell].gizmo.queue_free()
		if not tile_at[cell].get("floor", null) == null:
			tile_at[cell].floor.queue_free()
		if not tile_at[cell].get("prop", null) == null:
			tile_at[cell].prop.queue_free()
	
	tile_at[cell] = {
		"floor": null,
		"prop": null,
		"gizmo": make_gizmo(cell),
	}
	
	if delete_info and cell in tile_info:
		tile_info.erase(cell)

func gen_tile(cell:Vector2i):
	rst_tile(cell)
	
	if not cell in tile_info:
		return
	
	tile_at[cell].floor = make_floor(cell)
	tile_at[cell].prop = make_prop(cell)
	#tile_at[cell].gizmo = tile_at[cell].get("gizmo", make_gizmo(cell))  # if gizmo is missing, make a new one.
	# If the gizmo wasn't missing, we'll just have to modify it.
	tile_at[cell].gizmo.modulate = color_code[tile_info[cell].kind]
	tile_at[cell].gizmo.modulate.a = 0.2
	
	# Apply transformations to objects appropriatedly.
	if not tile_at[cell].floor == null:
		tile_at[cell].floor.position = Vector3(cell.x, 0, cell.y)
		tile_at[cell].floor.rotation.y = tile_info[cell].floor_rotation * TAU / 4
	
	if not tile_at[cell].prop == null:
		tile_at[cell].prop.position = Vector3(cell.x, 0, cell.y)
		tile_at[cell].prop.rotation.y = tile_info[cell].prop_rotation * TAU / 4
		
#endregion

#region Handle requests/input
func set_tile(cell:Vector2i, data:Dictionary):
	## Returns whether the operation was successful
	
	if not cell in tile_at:
		return false # Tried adding data outside the bounds of the grid.

	if not data.floor.name in floor_list:
		data.floor["texture"] = load(data.floor.path)
		floor_list[data.floor.name] = data.floor
	
	var prop_idx = prop_list.find(data.prop)
	if prop_idx == -1:
		prop_idx = prop_list.size()
		prop_list.append(data.prop)
	
	tile_info[cell] = {
		"kind": data.kind,
		"prop": prop_idx,
		"floor": data.floor.name,
		"prop_rotation": prop_rot,
		"floor_rotation": floor_rot,
	}
	
	gen_tile(cell)
	return true

func rotate_floor(cell:Vector2i):
	### Returns whether the operation was successful
	if not cell in tile_info:
		return false
	if tile_at[cell].get("floor", null) == null:
		return false
	floor_rot = wrapi(tile_info[cell].floor_rotation + 1, 0, 4)
	tile_info[cell].floor_rotation = floor_rot
	tile_at[cell].floor.rotation.y = floor_rot * TAU / 4
	return true

func rotate_prop(cell:Vector2i):
	## Returns whether the operation was successful
	if not cell in tile_info:
		return false
	if tile_at[cell].get("prop", null) == null:
		return false
	prop_rot = wrapi(tile_info[cell].prop_rotation - 1, 0, 4)
	tile_info[cell].prop_rotation = prop_rot
	tile_at[cell].prop.rotation.y = prop_rot * TAU / 4
	return true

func shift_map(dir:Vector2i):
	## Move all contents of the map towards a vector.
	## This isn't very efficient because it regenerates all the nodes and map,
	## but take it or leave it.
	
	var new_info : Dictionary
	for coord in tile_info:
		var new_coord = coord + dir
		new_info[new_coord] = tile_info[coord]
	tile_info = new_info
	
	# Regenerating map
	for x in range(reach.x):
		for y in range(reach.y):
			var cell = Vector2i(x,y)
			
			# Deleting existing map contents without clearing references to stuff.
			if cell in tile_at:
				if not tile_at[cell].get("gizmo", null) == null:
					tile_at[cell].gizmo.queue_free()
				if not tile_at[cell].get("floor", null) == null:
					tile_at[cell].floor.queue_free()
				if not tile_at[cell].get("prop", null) == null:
					tile_at[cell].prop.queue_free()
				tile_at.erase(cell)
			
			gen_tile(cell)
#endregion

#region Create nodes
func make_gizmo(cell:Vector2i):
	var gizmo = Sprite3D.new()
	gizmo.position = Vector3(cell.x, 0.0, cell.y)
	gizmo.texture = gridcell_texture
	gizmo.pixel_size = 1.0 / gridcell_texture.get_width()  #NOTE Careful to no do intenger division here!
	gizmo.axis = Vector3.AXIS_Y
	gizmo.no_depth_test = true
	if cell in tile_info:
		gizmo.modulate = color_code[tile_info[cell].kind]
	else:
		gizmo.modulate = color_code[TILE.FULL]
	gizmo.modulate.a = 0.2
	%gizmoed.add_child(gizmo)
	return gizmo

func make_prop(cell:Vector2i):
	if tile_info[cell].kind in [TILE.PASS, TILE.LADD]:
		return null
	var node = load(prop_list[tile_info[cell].prop]).instantiate()
	%proped.add_child(node)
	return node

func make_floor(cell:Vector2i):
	var node
	var data = floor_list[tile_info[cell].floor]
	match data.kind:
		0: # static
			node = Sprite3D.new()
			node.texture = data.texture
			node.region_enabled = true
			node.region_rect = data.rect
			node.pixel_size = 1.0 / data.rect.size.x  #NOTE Careful to no do intenger division here!
			node.shaded = true
			node.axis = Vector3.AXIS_Y
			node.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			node.transparent = false  # Do we need this? It causes problems with overlapping transparent objects.
		1: # animated
			return null
		2: # custom scene
			return null
	%floored.add_child(node)
	return node

#endregion

#region Manage Navigation
func make_navgrids():
	# Produce AStar navigation from tile info.
	navgrid_strict = AStarGrid2D.new()
	navgrid_strict.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	navgrid_strict.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	navgrid_strict.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	navgrid_strict.jumping_enabled = false
	navgrid_strict.region = Rect2i(Vector2i.ZERO, reach)
	navgrid_strict.update()
	
	navgrid_all = AStarGrid2D.new()
	navgrid_all.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	navgrid_all.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	navgrid_all.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	navgrid_all.jumping_enabled = false
	navgrid_all.region = Rect2i(Vector2i.ZERO, reach)
	navgrid_all.update()
	
	for x in range(reach.x):
		for y in range(reach.y):
			var cell = Vector2i(x, y)
			var tile = tile_info.get(cell, null)
			if tile == null:
				continue
			match tile.kind:
				TILE.FULL:
					navgrid_strict.set_point_solid(cell, true)
					navgrid_all.set_point_solid(cell, true)
				TILE.HALF:
					navgrid_strict.set_point_weight_scale(cell, 3)
					navgrid_all.set_point_solid(cell, true)

func get_trajectory(origin:Vector2i, destination:Vector2i, max_steps = -1) -> Array[Vector2i]:
	var navgrid := duplicate_navigation( navgrid_all )
	if not navgrid.is_in_bounds(destination.x, destination.y):
		return []
	for each in get_children():
		if not each is Interactable:
			continue
		for reserved_coord in each.get_grid_blocks():
			navgrid.set_point_solid(reserved_coord, true)
	
	#TODO Account for the fact that the character might be on another TacMaps
	var trajectory = navgrid.get_id_path(origin, destination, true)
	trajectory.pop_front()  # Remove the tile where the character is sitting.
	trajectory.slice(0, max_steps)  # Constraining the trajectory to how many steps the character can take.
	
	if not trajectory.is_empty():
		var last_tile = tile_info.get(trajectory.back(), {"kind":TILE.PASS} )
		while last_tile.kind != TILE.PASS and not trajectory.is_empty():
			# Eliminate destination tiles until there's one the character can sit on.
			last_tile = tile_info.get( trajectory.pop_back(), {"kind":TILE.PASS} )
			
	return trajectory

## Tests if there are Interactable class derived objects at the given coordinate.
## Returns false in such cases. Optionally can only account for characters on this grid.
func is_blocked(coord : Vector2i, only_characters := false):
	for each in get_children():
		if not each is Interactable:
			continue
		if not each.is_in_group("is_terrain_relevant"):
			continue
		if coord in each.get_grid_blocks():
			return true
	return false

## Tests both is a coordinate is a valid cell within the grid and not an obstacle.
## Returns false in those cases. Optionally can choose which navgrid to use.
func is_solid(coord : Vector2i, all_obstacles := true) -> bool:
	if not navgrid_all.is_in_bounds(coord.x, coord.y):
		return true
	var navgrid = [navgrid_strict, navgrid_all][int(all_obstacles)]
	if navgrid.is_point_solid(coord):
			return true
	return false
	
#endregion
