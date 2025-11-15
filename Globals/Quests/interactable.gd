extends Area3D
class_name Interactable

signal interacted(trigger:Node3D, chara:Character)  ## The player tried to click on this object. Returns which object this is.

@export var interact_distance : float = 2.4  ## How far, in meters, can a character be from this prop and still allow it to interact.

var mouse_hover : bool  # Is the mouse over this area?

func _ready():
	input_ray_pickable = true
	collision_layer = Ses.phys_layer["UI_Hacks"]
	collision_mask = Ses.phys_layer["Interactable"]

func _mouse_enter() -> void:
	mouse_hover = true
func _mouse_exit() -> void:
	mouse_hover = false
func _unhandled_input(event: InputEvent) -> void:
	## A player's attemt to interact with this object.
	if event.is_action_released("chara_interact") and mouse_hover:
		var chara_coord = Ses.curr_unit().get_global_coord()
		var self_coord = get_global_coord()
		if chara_coord.distance_to(self_coord) <= interact_distance:
			interacted.emit(self, Ses.curr_unit())


func npc_interaction(chara:Character) -> bool:
	## It returns if interaction was successful.
	var npc_coord = chara.get_global_coord()
	var prop_coord = get_global_coord()
		
	if prop_coord.distance_to(npc_coord) > interact_distance:
		return false
	
	interacted.emit(self, chara)
	return true


func get_grid() -> TacMap:
	## In which Tactical Grid is this object performing?
	## By default it assumes the object is a child of the grid,
	## But only characters do this.
	return get_parent()

func get_grid_coord(grid_offset := Vector3.ZERO) -> Vector2i:
	## This method returns the coord relative parent, assuming it is the a tactical grid.
	## If not, then supply the offset.
	var coord = position + grid_offset
	coord = coord.snapped(Vector3.ONE)
	return Vector2i(coord.x, coord.z)

func get_global_coord(offset := Vector3.ZERO) -> Vector2i:
	## This method neglects where this node would be in the scene tree.
	## If some reference is desirable, provide an offset.
	var coord = global_position.snapped(Vector3.ONE) + offset
	return Vector2i(coord.x, coord.z)
