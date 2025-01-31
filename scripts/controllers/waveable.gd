extends Sprite2D

@export var amplitude: float = 10
@export var freq: float = 5.0
var original_pos: Vector2
var elapsed_time: float

@export var vertical: bool = true

func _ready():
	original_pos = position

func _process(delta: float):
	elapsed_time += delta
	
	position = original_pos
	if vertical:
		position.y += sin(elapsed_time * freq + position.x) * amplitude
	else:
		var x_offset = ((sin(elapsed_time * freq + global_position.y) * amplitude) + 1)/2
		position.x += x_offset
