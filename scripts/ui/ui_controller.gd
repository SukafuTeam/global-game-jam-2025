extends Control
class_name UIController

@onready var filter: ColorRect = $Filter
@onready var filter_material: ShaderMaterial

@export var filter_blur_amount: float = 0.0
@export var filter_mix_amount: float = 0.0

@onready var p1: PlayerUIController = $P1UI
@onready var p2: PlayerUIController = $P2UI

@onready var timer_label: RichTextLabel = $TimerContainer/TimerLabel
@onready var star_controller: UIStarContainer = $StartContainer

@onready var round_label: Label = $RoundLabel
@onready var startup_label: Label = $StartupLabel

@onready var winner_splash: WinnerSplashController = $WinnerSplash

var ending: bool

func _ready() -> void:
	round_label.visible = true
	ending = false
	filter.visible = true
	filter_material = filter.material as ShaderMaterial
	filter_blur_amount = 0.0
	filter_mix_amount = 0.0
	filter_material.set_shader_parameter("mix_amount", filter_mix_amount);
	filter_material.set_shader_parameter("blur_amount", filter_blur_amount);

func _process(_delta: float):
	filter_material.set_shader_parameter("mix_amount", filter_mix_amount);
	filter_material.set_shader_parameter("blur_amount", filter_blur_amount);

func take_damage(player: InputController.PLAYER, new_health: int):
	match player:
		InputController.PLAYER.P1:
			p1.take_damage(new_health)
		InputController.PLAYER.P2:
			p2.take_damage(new_health)

func set_startup_label(value: String):
	var tween = create_tween()
	tween.tween_property(
		startup_label,
		"scale",
		Vector2.ONE * 1.8,
		0.2
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func(): startup_label.text = value)
	tween.tween_property(
		startup_label,
		"scale",
		Vector2.ONE,
		0.2
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

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
	
	GameController.current_round += 1
	
	if GameController.p1_victories == 1 or GameController.p2_victories == 1:
		var winner_data = p1.player.data if winner == InputController.PLAYER.P1 else p2.player.data
		var loser_data = p1.player.data if winner == InputController.PLAYER.P2 else p2.player.data
		winner_splash.show_splash(winner_data, loser_data)
		return
	
	SceneTransition.change_scene(get_tree().current_scene.scene_file_path)
