extends Node2D

@export var ui: UIController
@export var player1: PlayerController
@export var player2: PlayerController

var dead: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player1.died.connect(finished_game)
	player2.died.connect(finished_game)
	
	player1.took_damage.connect(func(health):
		ui.take_damage(InputController.PLAYER.P1,health)
	)
	player2.took_damage.connect(func(health):
		ui.take_damage(InputController.PLAYER.P2, health)
	)

func finished_game():
	if dead:
		return
	
	dead = true
	player1.interactive = false
	player2.interactive = false
	player1.velocity = Vector2.ZERO
	player2.velocity = Vector2.ZERO
	await GameController.hit_stop(1.0)
	get_tree().reload_current_scene()
