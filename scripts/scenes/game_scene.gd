extends Node2D
class_name GameScene

const CRUSHER_SPEED: float = 100.0

@export var ui: UIController
@export var player1: PlayerController
@export var player2: PlayerController
@export var active: bool
@export var level_time: float = 60.0

@export var number_sfx: AudioStream
@export var go_sfx: AudioStream

@export var arena_song: AudioStream

@export var left_crusher: CrusherController
@export var right_crusher: CrusherController

@export var arenas: Array[Node2D] = []
@export var backgrounds: Array[Node2D] = []

var dead: bool

func _ready() -> void:
	
	for i in range(arenas.size()):
		if i == GameController.current_round - 1:
			var a = arenas[i] as TileMapLayer
			a.enabled = true
			a.visible = true
			continue
		
		arenas[i].queue_free()

	for i in range(backgrounds.size()):
		if i == GameController.current_round - 1:
			backgrounds[i].visible = true
			continue
		backgrounds[i].queue_free()
	
	SoundController.stop_bgm()
	SoundController.current_bgm_name = ""
	
	player1.died.connect(finished_game)
	player2.died.connect(finished_game)
	
	player1.took_damage.connect(func(health):
		ui.take_damage(InputController.PLAYER.P1,health)
		if health == 0:
			# TODO: add player's victory
			ui.end_game(InputController.PLAYER.P2)
	)
	player2.took_damage.connect(func(health):
		ui.take_damage(InputController.PLAYER.P2, health)
		if health == 0:
			ui.end_game(InputController.PLAYER.P1)
	)
	
	ui.p1.player = player1
	ui.p2.player = player2
	
	startup_sequence()


func _process(delta: float):
	if active:
		if level_time <= 0.0:
			left_crusher.set_active()
			right_crusher.set_active()
			if left_crusher.position.x < -40:
				left_crusher.position.x += CRUSHER_SPEED * delta
			if right_crusher.position.x > 1960:
				right_crusher.position.x -= CRUSHER_SPEED * delta
			GameController.camera.stress = Vector2.ONE * 0.4
	
	var current_sec = int(level_time)
	if active:
		current_sec += 1
	if current_sec > 60:
		current_sec = 60
	
	if level_time <= 0.0:
		level_time = 0.0
		current_sec = 0
	
	var res = "[center]"
	res += "[wave amp=30 freq=-6]"
	if level_time <= 10:
		res += "[shake rate=30.0 level=10 connected=1]"
	res += str(current_sec)
	if level_time <= 10:
		res += "[/shake]"
	res += "[/wave]"
	res += "[/center]"
	ui.timer_label.text = res

func startup_sequence():
	player1.interactive = false
	player2.interactive = false
	
	ui.round_label.scale = Vector2.ZERO
	ui.round_label.text = "Round "+ str(GameController.current_round)
	
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(
		ui.round_label,
		"scale",
		Vector2.ONE,
		0.2
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		SoundController.play_sfx(number_sfx)
		ui.set_startup_label("3")
	)
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		SoundController.play_sfx(number_sfx)
		ui.set_startup_label("2"))
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		SoundController.play_sfx(number_sfx)
		ui.set_startup_label("1")
	)
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		ui.set_startup_label("Go!")
		SoundController.play_sfx(go_sfx)
		player1.interactive = true
		player2.interactive = true
		active = true
		SoundController.change_bgm("arena", arena_song)
	)
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		ui.set_startup_label("")
	)
	tween.parallel().tween_property(
		ui.round_label,
		"scale",
		Vector2.ONE * 1.2,
		0.2
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func(): ui.round_label.text = "")

func finished_game():
	if dead:
		return
	
	active = false
	dead = true
	player1.interactive = false
	player2.interactive = false
	player1.frozen = true
	player2.frozen = true
	player1.velocity = Vector2.ZERO
	player2.velocity = Vector2.ZERO
