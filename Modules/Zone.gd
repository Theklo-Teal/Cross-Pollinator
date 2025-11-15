extends Area3D
class_name Zone

## This creates a region of the map that tells the character if they are in any special area.

func _ready() -> void:
	collision_layer = 0
	collision_mask = Ses.phys_layer["Character"]
	input_ray_pickable = false
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area):
	if area is Character:
		area.entered_zone(name)
		get_tree().call_group("track_chara_zone", "_on_chara_changed_zone", area)

func _on_area_exited(area):
	if area is Character:
		area.exited_zone(name)
		get_tree().call_group("track_chara_zone", "_on_chara_changed_zone", area)
