extends Node2D

@export var animatable_nodes: Array[Node2D] = []

func _ready():
	var tween = create_tween()
	tween.tween_interval(1.0)
	
	var original_pos: Array[Vector2] = []
	
	for node in animatable_nodes:
		original_pos.append(node.global_position)
	
	for i in range(animatable_nodes.size()):
		var node = animatable_nodes[i]
		node.global_position.x -= 1000
		tween.tween_property(
			node,
			"global_position",
			original_pos[i],
			0.4
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
