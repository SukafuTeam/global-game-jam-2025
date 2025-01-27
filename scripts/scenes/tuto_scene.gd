extends Node2D

@export var time_to_hold: float = 1.0
var current_holding_time: float

@onready var button_icon: TextureRect = $"Select Button/Icon"
@onready var texture_progress_bar: TextureProgressBar = $"Select Button/Icon/TextureProgressBar"

@export var confirm_sfx: AudioStream

var moving_forward: bool

func _process(delta: float):
	if moving_forward:
		return
	
	if Input.is_action_pressed("p1_jump") or Input.is_action_pressed("p2_jump"):
		current_holding_time += delta
		button_icon.scale = lerp(button_icon.scale, Vector2.ONE * 1.3, 10 * delta)
		if current_holding_time > time_to_hold:
			SceneTransition.change_scene(Constants.ARENA_SCENE)
			moving_forward = true
			SoundController.play_sfx(confirm_sfx)
	else:
		current_holding_time = 0.0
		button_icon.scale = Vector2.ONE
		
	var hold_percent = inverse_lerp(0.0, time_to_hold, current_holding_time)
	texture_progress_bar.value = lerp(0.0, 100.0, hold_percent)
