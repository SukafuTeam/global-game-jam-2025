extends Node2D
class_name UIHeartController

const AMPLITUDE: float = 5
@export var SPEED: float = 5


@onready var container: Sprite2D = $container
@onready var heart: Sprite2D = $heart

var full: bool
var original_position: Vector2
var elapsed_time: float

func _ready() -> void:
	original_position = position
	full = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !full:
		position.y = original_position.y
		heart.position.x = cos(elapsed_time * SPEED * 10) * AMPLITUDE * elapsed_time * 10
		
		return
	
	elapsed_time += delta
	
	var y = original_position.y
	y += sin(elapsed_time * SPEED + global_position.x) * AMPLITUDE
	
	position.y = y
	
func set_empty():
	full = false
	elapsed_time = 0.0
	
	var tween = create_tween()
	tween.tween_property(
		container,
		"scale",
		Vector2.ZERO,
		1.0
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(
		heart,
		"position:y",
		original_position.y - 100,
		1.0
	)
	tween.parallel().tween_property(
		heart,
		"modulate:a",
		0.0,
		1.0
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	
	heart.visible = false
	container.visible = false
