extends Resource
class_name CharacterLore

enum RANK {
	PRIVATE,
	SARGEANT,
	LIEUTENANT,
	MAJOR,
	COLONEL
}

const rank_names := ["Private", "Sargeant", "Lieutenant", "Major", "Colonel"]

@export_group("Lore")
@export var rank : RANK  ## The default rank of the character.
@export var faction : String  ## Alliagence of this character in the story.
@export var org_codename : String  ## Within their boss organization reports, what they are referred to.
@export var squad_codename : String  ## During missions, how they are referred by their squad.
@export_enum("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-") var bloodtype : String
@export_enum("FEMALE", "MALE", "[AGARTHIAN]") var sex : String
@export_multiline var likes : String
@export_multiline var dislikes : String
@export_multiline var hobbies : String


func get_rank_name() -> String:
	return rank_names[rank]
