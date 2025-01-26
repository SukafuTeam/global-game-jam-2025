extends Area2D
class_name ArenaBound

enum DIRECTION {
	VERTICAL,
	HORIZONTAL
}

@export var direction: DIRECTION
@export var target_pos: float

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D):
	match direction:
		DIRECTION.HORIZONTAL:
			body.global_position.x = target_pos
		DIRECTION.VERTICAL:
			body.global_position.y = target_pos
