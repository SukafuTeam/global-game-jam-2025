extends RigidBody2D
class_name ScenarioItem

@export var break_speed: float = 1500.0
@export var impulse_modifier: float = 0.5

@onready var sprite: Sprite2D = $Sprite
@onready var break_area: Area2D = $BreakArea

@export var textures: Array[Texture] = []

var broken: bool

func _ready():
	break_area.body_entered.connect(on_player_entered)
	sprite.texture = textures.pick_random()

func on_player_entered(other: Node2D):
	if !(other is PlayerController):
		return
	
	var ball = other as PlayerController
	
	if !broken:
		if ball.last_velocity.length() < break_speed:
			return
	
	broken = true
	apply_impulse(
		ball.last_velocity * impulse_modifier
	)
