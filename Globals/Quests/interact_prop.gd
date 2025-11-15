@tool
extends Interactable
class_name InteractProp

@export_enum("Can Be Stepped On", "Half Obstacle", "Full Obstacle") var solidity : int = 0
@export_group("Character Direction Requirement", "detect_")
@export_enum("None", "Front", "Back", "Both") var detect_z : int = 3  ## Character doing the interaction can be in these directions of the object
@export_enum("None", "Right", "Left", "Both") var detect_x : int = 3  ## Character doing the interaction can be in these directions of the object

func _ready() -> void:
	super()
	
	collision_mask |= Ses.phys_layer["Terrain"]
	
	if solidity > 0:
		add_to_group("is_terrain_relevant")

func get_grid():
	var area = get_overlapping_areas()[0]
	if not area == null:
		return get_node(area.get_meta("parent_tacmap"))
	return null  # No TacMap was found for this Prop
