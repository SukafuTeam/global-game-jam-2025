extends Control
class_name MenuScene

func _ready():
	GameController.reset()

func _process(delta: float):
	if Input.is_action_just_pressed("p1_jump") or Input.is_action_just_pressed("p2_jump"):
		SceneTransition.change_scene(Constants.CHAR_SELECT_SCENE)
	
	if Input.is_action_just_pressed("p1_dash") or Input.is_action_just_pressed("p2_dash"):
		get_tree().quit()
