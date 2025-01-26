extends Node2D

@export var ui: UIController
@export var player1: PlayerController
@export var player2: PlayerController
@export var active: bool
@export var level_time: float = 60.0

@export var number_sfx: AudioStream
@export var go_sfx: AudioStream

var dead: bool

func _ready() -> void:
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
		level_time -= delta
	
	if level_time <= 0.0:
		level_time = 0.0
	
	var res = "[center]"
	if level_time < 10:
		res += "[shake rate=30.0 level=10 connected=1]"
		res += str(int(level_time))
		res += "[/shake]"
	else:
		res += "[wave amp=30 freq=-6]"
		res += str(int(level_time))
		res += "[/wave]"
		
		
	res += "[/center]"
	ui.timer_label.text = res

func startup_sequence():
	player1.interactive = false
	player2.interactive = false
	
	var tween = create_tween()
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
	)
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		ui.set_startup_label("")
	)

func finished_game():
	if dead:
		return
	
	dead = true
	player1.interactive = false
	player2.interactive = false
	player1.frozen = true
	player2.frozen = true
	player1.velocity = Vector2.ZERO
	player2.velocity = Vector2.ZERO
