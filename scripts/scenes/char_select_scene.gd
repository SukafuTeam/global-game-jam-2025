extends Control
class_name CharSelectScene

const P1_BACK_POSITION: float = -800
const P1_FRONT_POSITION: float = 0
const P2_BACK_POSITION: float = 1000
const P2_FRONT_POSITION: float = -100

@export var p1_focus: int:
	set(value):
		if value != p1_focus:
			options[p1_focus].focused = false
			options[value].focused = true
			options[value].is_p1 = true
			update_p1_splash(options[value].get_data())
		p1_focus = value
		p1_cursor.position.x = options[value].position.x + 170
	get:
		return p1_focus
		
@export var p2_focus: int:
	set(value):
		if value != p2_focus:
			options[p2_focus].focused = false
			options[value].focused = true
			options[value].is_p1 = false
			update_p2_splash(options[value].get_data())
		p2_focus = value
		p2_cursor.position.x = options[value].position.x + 170
	get:
		return p2_focus

@export var options: Array[CharOptionController] = []

@export var p1_cursor: Node2D
@export var p2_cursor: Node2D

var moving_forward: bool

@export var move_sfx: AudioStream
@export var select_sfx: AudioStream
@export var cancel_sfx: AudioStream

@onready var p_1_splash_container = $P1SplashContainer
@onready var p_2_splash_container = $P2SplashContainer
@onready var p1_splash: TextureRect = $P1SplashContainer/P1Splash
@onready var p2_splash: TextureRect = $P2SplashContainer/P2Splash
@onready var p_1_char_name_label: RichTextLabel = $P1CharNameContainer/P1CharNameLabel
@onready var p_2_char_name_label: RichTextLabel = $P2CharNameContainer/P2CharNameLabel


var p1_splash_tween: Tween
var p2_splash_tween: Tween

func _ready():
	p1_focus = -1
	p2_focus = -1
	
	p1_focus = 0
	p2_focus = 3

func _process(_delta: float):
	if moving_forward:
		return
	
	if options[p1_focus].selected and options[p2_focus].selected:
		moving_forward = true
		tutorial()
		return
	
	if Input.is_action_just_pressed("p1_left"):
		p1_focus = move_left(p1_focus, p2_focus)
	if Input.is_action_just_pressed("p1_right"):
		p1_focus = move_right(p1_focus, p2_focus)
	if Input.is_action_just_pressed("p2_left"):
		p2_focus = move_left(p2_focus, p1_focus)
	if Input.is_action_just_pressed("p2_right"):
		p2_focus = move_right(p2_focus, p1_focus)
	
	if Input.is_action_just_pressed("p1_jump"):
		if !options[p1_focus].selected:
			options[p1_focus].selected = true
			select_p1(options[p1_focus].get_data())
			SoundController.play_sfx(select_sfx)
	if Input.is_action_just_pressed("p2_jump"):
		if !options[p2_focus].selected:
			options[p2_focus].selected = true
			select_p2(options[p2_focus].get_data())
			SoundController.play_sfx(select_sfx)
		
	if Input.is_action_just_pressed("p1_dash"):
		if options[p1_focus].selected:
			options[p1_focus].selected = false
			deselect_p1(options[p1_focus].get_data())
			SoundController.play_sfx(cancel_sfx)
	if Input.is_action_just_pressed("p2_dash"):
		if options[p2_focus].selected:
			options[p2_focus].selected = false
			deselect_p2(options[p2_focus].get_data())
			SoundController.play_sfx(cancel_sfx)

func move_left(current: int, enemy: int) -> int:
	if options[current].selected:
		return current
	
	SoundController.play_sfx(move_sfx)
	
	var target = current - 1
	if enemy == target:
		target -= 1
	if target < 0:
		target = 3
	if enemy == target:
		target -= 1
	return target

func move_right(current: int, enemy: int) -> int:
	if options[current].selected:
		return current
	
	SoundController.play_sfx(move_sfx)
	
	var target = current + 1
	if enemy == target:
		target += 1
	if target > 3:
		target = 0
	if enemy == target:
		target += 1
	return target

func tutorial():
	GameController.p1_index = p1_focus
	GameController.p2_index = p2_focus
	
	await get_tree().create_timer(1.0).timeout
	SceneTransition.change_scene(Constants.TUTO_SCENE)

func update_p1_splash(data: CharacterData):
	if p1_splash_tween:
		p1_splash_tween.kill()
	
	var res = "[wave amp=30 freq=-6]"
	res += data.char_name
	res += "[/wave]"
	p_1_char_name_label.text = res
	
	p1_splash.texture = data.splash_idle
	p1_splash.position.x = P1_BACK_POSITION
	
	p_1_splash_container.texture = data.splash_background
	
	p1_splash_tween = create_tween()
	p1_splash_tween.tween_property(
		p1_splash,
		"position:x",
		P1_FRONT_POSITION,
		0.2
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
func select_p1(data: CharacterData):
	if p1_splash_tween:
		p1_splash_tween.kill()
	
	p1_splash_tween = create_tween()
	p1_splash_tween.tween_property(
		p1_splash,
		"scale",
		Vector2.ONE * 1.2,
		0.1
	)
	p1_splash_tween.tween_callback(func(): p1_splash.texture = data.splash_selected)
	p1_splash_tween.tween_property(
		p1_splash,
		"scale",
		Vector2.ONE,
		0.1
	)

func deselect_p1(data: CharacterData):
	if p1_splash_tween:
		p1_splash_tween.kill()
		
	p1_splash_tween = create_tween()
	p1_splash_tween.tween_property(
		p1_splash,
		"scale",
		Vector2.ONE * 1.2,
		0.1
	)
	p1_splash_tween.tween_callback(func(): p1_splash.texture = data.splash_idle)
	p1_splash_tween.tween_property(
		p1_splash,
		"scale",
		Vector2.ONE,
		0.1
	)
	
func update_p2_splash(data: CharacterData):
	if p2_splash_tween:
		p2_splash_tween.kill()
	
	var res = "[right][wave amp=30 freq=-6]"
	res += data.char_name
	res += "[/wave][/right]"
	p_2_char_name_label.text = res
	
	p2_splash.texture = data.splash_idle
	p2_splash.position.x = P2_BACK_POSITION
	
	p_2_splash_container.texture = data.splash_background
	
	p2_splash_tween = create_tween()
	p2_splash_tween.tween_property(
		p2_splash,
		"position:x",
		P2_FRONT_POSITION,
		0.2
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func select_p2(data: CharacterData):
	if p2_splash_tween:
		p2_splash_tween.kill()
	
	p2_splash_tween = create_tween()
	p2_splash_tween.tween_property(
		p2_splash,
		"scale",
		Vector2.ONE * 1.2,
		0.1
	)
	p2_splash_tween.tween_callback(func(): p2_splash.texture = data.splash_selected)
	p2_splash_tween.tween_property(
		p2_splash,
		"scale",
		Vector2.ONE,
		0.1
	)

func deselect_p2(data: CharacterData):
	if p2_splash_tween:
		p2_splash_tween.kill()
	p2_splash.scale = Vector2.ONE
	p2_splash.texture = data.splash_idle
