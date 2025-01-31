extends Control
class_name MenuScene

enum State {
	MENU,
	EXIT,
	CREDITS
}

@export var menu_song: AudioStream
@onready var offset: Node2D = $LogoContainer/Offset
var elapsed_time: float = 0
@onready var logo_serra: Sprite2D = $"LogoContainer/Offset/Logo-serra"
@export var select_sfx: AudioStream
@export var back_sfx: AudioStream

@onready var exit_modal = $ExitModal
@onready var exit_panel = $ExitModal/Panel
var exit_tween: Tween

@onready var credits_modal = $CreditsModal
@onready var credits_panel = $CreditsModal/Panel
var credits_tween: Tween

var state: State

var next: bool:
	get:
		return Input.is_action_just_pressed("ui_next")

var back: bool:
	get:
		return Input.is_action_just_pressed("ui_back")



func _ready():
	GameController.reset()
	SoundController.change_bgm("menu", menu_song)
	
	exit_modal.visible = false
	exit_panel.scale = Vector2.ZERO
	
	credits_modal.visible = false
	credits_panel.scale = Vector2.ZERO
	
	state = State.MENU

func _process(delta: float):
	logo_serra.rotation_degrees += 300 * delta
	
	elapsed_time += delta
	var pos = sin(elapsed_time * 2) * 10
	offset.position.y = pos
	
	match state:
		State.MENU:
			if next:
				SoundController.play_sfx(select_sfx)
				SceneTransition.change_scene(Constants.CHAR_SELECT_SCENE)
			elif back:
				open_exit()
				SoundController.play_sfx(back_sfx)
				state = State.EXIT
			elif Input.is_action_just_pressed("ui_credits"):
				SoundController.play_sfx(select_sfx)
				open_credits()
				state = State.CREDITS
		State.EXIT:
			if next:
				get_tree().quit()
			elif back:
				close_exit()
				SoundController.play_sfx(back_sfx)
				state = State.MENU
		State.CREDITS:
			if back:
				SoundController.play_sfx(back_sfx)
				close_credits()
				state = State.MENU
		

func open_exit():
	if exit_tween:
		exit_tween.kill()
	
	exit_tween = create_tween()
	exit_modal.visible = true
	exit_tween.tween_property(
		exit_panel,
		"scale",
		Vector2.ONE,
		0.2
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func close_exit():
	if exit_tween:
		exit_tween.kill()
	
	exit_tween = create_tween()
	exit_tween.tween_property(
		exit_panel,
		"scale",
		Vector2.ZERO,
		0.2
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	exit_tween.tween_callback(func(): exit_modal.visible = false)
	
func open_credits():
	if credits_tween:
		credits_tween.kill()
	
	credits_modal.visible = true
	credits_tween = create_tween()
	credits_tween.tween_property(
		credits_panel,
		"scale",
		Vector2.ONE,
		0.2
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func close_credits():
	if credits_tween:
		credits_tween.kill()
	
	credits_tween = create_tween()
	credits_tween.tween_property(
		credits_panel,
		"scale",
		Vector2.ZERO,
		0.2
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	credits_tween.tween_callback(func(): credits_modal.visible = false)
	
