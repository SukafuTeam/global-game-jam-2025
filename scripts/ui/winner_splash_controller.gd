extends Node2D
class_name WinnerSplashController

const SPLASH_FRONT_POSITION: float = 0.0
const SPLASH_BACK_POSITION: float = -1100.0

@onready var confetti: CPUParticles2D = $Confetti
@onready var splash_background: TextureRect = $SplashBackground
@onready var splash_art: TextureRect = $SplashBackground/SplashArt
@onready var p_1_char_name_label: RichTextLabel = $SplashBackground/SplashArt/P1CharNameContainer/P1CharNameLabel
@onready var menu_button: NinePatchRect = $"Menu Button"

@onready var winner_label_shadow: RichTextLabel = $WinnerLabelShadow
@onready var cheer: AudioStreamPlayer = $Cheer
@onready var loser_portrait_container = $LoserPortraitContainer
@onready var loser_portrait = $LoserPortraitContainer/PortraitMask/LoserPortrait

@export var select_sfx: AudioStream

var star_1: Node2D
var star_2: Node2D

var interactible: bool

@export var nodes_to_hide: Array[Node] = []

func _ready():
	confetti.emitting = false
	splash_background.position.x = SPLASH_BACK_POSITION
	winner_label_shadow.scale = Vector2.ZERO
	menu_button.scale = Vector2.ZERO
	loser_portrait_container.scale = Vector2.ZERO
	
func _process(_delta: float):
	if interactible == false:
		return
	
	if Input.is_action_just_pressed("ui_back"):
		SoundController.play_sfx(select_sfx)
		SceneTransition.change_scene(Constants.MENU_SCENE)
		interactible = false
		cheer.stop()

func show_splash(winner_data: CharacterData, loser_data: CharacterData):
	cheer.play()
	SoundController.stop_bgm()
	SoundController.current_bgm_name = ""
	
	for node in nodes_to_hide:
		node.visible = false
	
	confetti.emitting = true
	confetti.color = winner_data.main_color
	splash_background.texture = winner_data.splash_background
	splash_background.position.x = SPLASH_BACK_POSITION
	splash_art.texture = winner_data.splash_selected
	
	var res = "[wave amp=30 freq=-6]"
	res += winner_data.char_name
	res += "[/wave]"
	p_1_char_name_label.text = res
	
	loser_portrait.texture = loser_data.damage_portrait
	
	winner_label_shadow.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(
		splash_background,
		"position:x",
		SPLASH_FRONT_POSITION,
		1.0
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		winner_label_shadow,
		"scale",
		Vector2.ONE,
		0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		loser_portrait_container,
		"scale",
		Vector2(-1.5, 1.5),
		0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		menu_button,
		"scale",
		Vector2.ONE,
		0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(func():
		interactible = true
	)
	
