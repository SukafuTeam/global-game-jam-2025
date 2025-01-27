extends Node2D

@export var game_scene: GameScene

func _process(delta):
	if game_scene.active:
		game_scene.level_time -= delta
