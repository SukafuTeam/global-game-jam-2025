extends Node

@export var test_constant: String = "test"

@export var muscle_char: CharacterData
@export var pop_char: CharacterData
@export var office_char: CharacterData
@export var farm_char: CharacterData

func get_character(index: int) -> CharacterData:
	match index:
		0:
			return muscle_char
		1:
			return pop_char
		2:
			return office_char
	return farm_char
