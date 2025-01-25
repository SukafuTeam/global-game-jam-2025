extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var time_limits: Vector2 = Vector2(0.3, 10.0)
var current_time_limit: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_time_limit = 5.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_time_limit -= delta
	
	if current_time_limit < 0.0:
		animation_player.play("lightning")
		current_time_limit = randf_range(time_limits.x, time_limits.y)
