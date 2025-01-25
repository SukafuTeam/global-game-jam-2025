extends Control
class_name UIController

@onready var filter: ColorRect = $Filter
@onready var confetti: CPUParticles2D = $Confetti

@onready var p1: PlayerUIController = $P1UI
@onready var p2: PlayerUIController = $P2UI

func _ready() -> void:
	filter.visible = false
	confetti.emitting = false

func take_damage(player: InputController.PLAYER, new_health):
	match player:
		InputController.PLAYER.P1:
			p1.take_damage(new_health)
		InputController.PLAYER.P2:
			p2.take_damage(new_health)
