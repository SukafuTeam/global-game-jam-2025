extends Node2D

func _process(_delta: float):
	if Input.is_action_just_pressed("p1_start") or Input.is_action_just_pressed("p2_start"):
		SceneTransition.change_scene(Constants.ARENA_SCENE)
	
	if Input.is_action_just_pressed("p1_dash") or Input.is_action_just_pressed("p2_dash"):
		SceneTransition.change_scene(Constants.CHAR_SELECT_SCENE)
