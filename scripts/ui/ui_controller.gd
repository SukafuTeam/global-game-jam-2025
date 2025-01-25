extends Control
class_name UIController

@onready var filter: ColorRect = $Filter
@onready var filter_material: ShaderMaterial
@onready var confetti: CPUParticles2D = $Confetti

@export var filter_blur_amount: float = 0.0
@export var filter_mix_amount: float = 0.0

@onready var p1: PlayerUIController = $P1UI
@onready var p2: PlayerUIController = $P2UI

@onready var timer_label: RichTextLabel = $TimerContainer/TimerLabel
@onready var star_controller: UIStarContainer = $StartContainer

var ending: bool

func _ready() -> void:
	ending = false
	filter.visible = true
	confetti.emitting = false
	filter_material = filter.material as ShaderMaterial
	filter_blur_amount = 0.0
	filter_mix_amount = 0.0
	filter_material.set_shader_parameter("mix_amount", filter_mix_amount);
	filter_material.set_shader_parameter("blur_amount", filter_blur_amount);

func _process(delta: float):
	filter_material.set_shader_parameter("mix_amount", filter_mix_amount);
	filter_material.set_shader_parameter("blur_amount", filter_blur_amount);

func take_damage(player: InputController.PLAYER, new_health: int):
	match player:
		InputController.PLAYER.P1:
			p1.take_damage(new_health)
		InputController.PLAYER.P2:
			p2.take_damage(new_health)

func end_game(winner: InputController.PLAYER):
	if ending:
		return
	
	ending = true
	var tween = create_tween()
	tween.tween_property(self, "filter_blur_amount", 4.5, 1.0)
	tween.parallel().tween_property(self, "filter_mix_amount", 0.3, 1.0)
	
	await tween.finished
	
	await star_controller.final_sequence(winner)
	
	await get_tree().create_timer(2.0).timeout
	
	GameController.round += 1
	
	# TODO: if has two wins, show splash
	
	# TODO: otherwise, goes to next arena
	
	# TODO: simulate next stage
	get_tree().reload_current_scene()
