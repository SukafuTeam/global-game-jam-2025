extends Node

const MENU_SCENE: String = "res://scenes/menu_scene.tscn"
const CHAR_SELECT_SCENE: String = "res://scenes/char_select_scene.tscn"
const TUTO_SCENE: String = "res://scenes/tuto_scene.tscn"
const ARENA_SCENE: String = "res://scenes/arena_scene.tscn"

@export var test_constant: String = "test"

@export var p1_color: Color
@export var p2_color: Color

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
