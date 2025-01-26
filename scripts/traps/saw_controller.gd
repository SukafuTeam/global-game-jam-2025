extends Area2D
class_name SawController

const ROTATION_SPEED: float = 300.0

@onready var sprite: Sprite2D = $Sprite2D

func _process(delta: float):
	sprite.rotation_degrees += ROTATION_SPEED * delta
