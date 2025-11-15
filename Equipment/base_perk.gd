extends Resource
class_name CharacterPerk

## Defines the perks and ailments of characters.

@export var title := "Unknown"
@export_multiline var description := "Not a recognized Perk or Ailment."
@export var atlas : AtlasTexture = preload("res://Assets/Textures/perks_status.tres")
