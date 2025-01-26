extends Control
class_name MenuScene

@export var menu_song: AudioStream

func _ready():
	GameController.reset()
	
	SoundController.change_bgm("menu", menu_song)

func _process(_delta: float):
	if Input.is_action_just_pressed("p1_jump") or Input.is_action_just_pressed("p2_jump"):
		SceneTransition.change_scene(Constants.CHAR_SELECT_SCENE)
	
	if Input.is_action_just_pressed("p1_dash") or Input.is_action_just_pressed("p2_dash"):
		get_tree().quit()
