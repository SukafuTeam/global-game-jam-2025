extends Control

@onready var background: ColorRect = $TextureRect
var transitioning: bool

func _ready():
	background.position.x = -2000


func change_scene(new_scene: String):
	if transitioning:
		return
	
	background.position.x = -2000
	transitioning = true
	var tween = create_tween()
	tween.tween_property(
		background,
		"position:x",
		0.0,
		1.0
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(new_scene)
	)
	tween.tween_property(
		background,
		"position:x",
		2000,
		1.0
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func():
		transitioning = false
	)
