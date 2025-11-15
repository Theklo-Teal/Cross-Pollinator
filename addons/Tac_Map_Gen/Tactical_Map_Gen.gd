@tool
@icon("tac_map.png")
extends Node3D
class_name TacMap

## This script is intended to define and instantiate the packed scene of the actual TacMap node.
## I guess it also keeps static variables and functions, I guess.

var plugin : EditorPlugin

func _enter_tree():
	if Engine.is_editor_hint():
		var node_scene = preload("Tac_Map_Node.tscn").instantiate()
		node_scene.plugin = plugin
		get_parent().add_child(node_scene)
		node_scene.owner = get_tree().edited_scene_root
		queue_free()


#region Analysing the Grid
enum TILE {
	PASS,
	HALF,
	FULL,
	LADD,
}


static func contour_shape(shape : Array[Vector2i], boundary : Array[Vector2i] = []) -> Array[Vector2i]:
	## Find grid coordinates which are adjacent to a given tile.
	## It can take several tiles, as if contouring the shape produced.
	## Optionally, include a list of tiles allowed to be returned, as a boundary.
	var contour : Array[Vector2i]
	for coord in shape:
		for adjacent in Math.adjacent_cells(coord):
			var rules = [
				adjacent in shape,
				adjacent in contour,
				not ( adjacent in boundary or boundary.is_empty() ),  # If the boundary is empty, we ignore that feature.
				]
			if true in rules:  # The rules exclude coordinates from the solution.
				continue
			else:
				contour.append(adjacent)
	return contour

#endregion
