extends Node2D
class_name PlayerUIController


@export var hearts: Array[UIHeartController] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	
func take_damage(new_health: int):
	for i in range(hearts.size()):
		if hearts[i].full:
			if new_health <= i:
				hearts[i].set_empty()
	
	
