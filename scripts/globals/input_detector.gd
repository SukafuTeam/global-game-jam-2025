extends Node

signal input_changed(player_index:int)

enum GamepadType {XBOX, PLAYSTATION, NINTENDO}

var current_p1_gamepad_type: GamepadType
var p1_is_gamepad: bool:
	set(value):
		if value == true and p1_is_gamepad == false:
			# detect controller type everytime we change input to gamepad
			current_p1_gamepad_type = detect_controller_type(0)
		var should_emit = false
		if value != p1_is_gamepad:
			should_emit = true
		p1_is_gamepad = value
		if should_emit:
			input_changed.emit(0)
	get:
		return p1_is_gamepad

var current_p2_gamepad_type: GamepadType
var p2_is_gamepad: bool:
	set(value):
		if value == true and p2_is_gamepad == false:
			# detect controller type everytime we change input to gamepad
			current_p2_gamepad_type = detect_controller_type(1)
		var should_emit = false
		if value != p2_is_gamepad:
			should_emit = true
		p2_is_gamepad = value
		if should_emit:
			input_changed.emit(1)
	get:
		return p2_is_gamepad

# Input textures
@export_subgroup("Jump Fields")
@export var jump_texture_xbox: Texture2D
@export var jump_texture_playstation: Texture2D
@export var jump_texture_keyboard_p1: Texture2D
@export var jump_texture_keyboard_p2: Texture2D
@export var next_texture_keyboard: Texture2D
@export var jump_texture_nintendo: Texture2D
var current_p1_jump_texture: Texture2D:
	get:
		if !p1_is_gamepad:
			return jump_texture_keyboard_p1
		match current_p1_gamepad_type:
			GamepadType.PLAYSTATION:
				return jump_texture_playstation
			GamepadType.NINTENDO:
				return jump_texture_nintendo
		return jump_texture_xbox
var current_p2_jump_texture: Texture2D:
	get:
		if !p2_is_gamepad:
			return jump_texture_keyboard_p2
		match current_p2_gamepad_type:
			GamepadType.PLAYSTATION:
				return jump_texture_playstation
			GamepadType.NINTENDO:
				return jump_texture_nintendo
		return jump_texture_xbox

var current_next_texture: Texture2D:
	get:
		if !p1_is_gamepad:
			return next_texture_keyboard
		match current_p1_gamepad_type:
			GamepadType.PLAYSTATION:
				return jump_texture_playstation
			GamepadType.NINTENDO:
				return jump_texture_nintendo
		return jump_texture_xbox

@export_subgroup("Back Fields")
@export var back_texture_xbox: Texture2D
@export var back_texture_playstation: Texture2D
@export var back_texture_keyboard: Texture2D
@export var back_texture_nintendo: Texture2D
var current_back_texture: Texture2D:
	get:
		if !p1_is_gamepad:
			return back_texture_keyboard
		match current_p1_gamepad_type:
			GamepadType.PLAYSTATION:
				return back_texture_playstation
			GamepadType.NINTENDO:
				return back_texture_nintendo
		return back_texture_xbox

@export_subgroup("Credits Fields")
@export var credits_texture_xbox: Texture2D
@export var credits_texture_playstation: Texture2D
@export var credits_texture_keyboard: Texture2D
@export var credits_texture_nintendo: Texture2D
var current_credits_texture: Texture2D:
	get:
		if !p1_is_gamepad:
			return credits_texture_keyboard
		match current_p1_gamepad_type:
			GamepadType.PLAYSTATION:
				return credits_texture_playstation
			GamepadType.NINTENDO:
				return credits_texture_nintendo
		return credits_texture_xbox

func _input(event):
	var p1_move_input = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	var p2_move_input = Vector2(Input.get_joy_axis(1, JOY_AXIS_LEFT_X), Input.get_joy_axis(1, JOY_AXIS_LEFT_Y))
	
	if Input.is_action_just_pressed("p1_keys") or (event is InputEventMouse):
		p1_is_gamepad = false
	elif Input.is_action_just_pressed("p1_pad") or p1_move_input.length() > 0.1:
		p1_is_gamepad = true
		
	if Input.is_action_just_pressed("p2_keys"):
		p2_is_gamepad = false
	elif Input.is_action_just_pressed("p2_pad") or p2_move_input.length() > 0.1:
		p2_is_gamepad = true

func detect_controller_type(index: int) -> GamepadType:
	var raw_name = Input.get_joy_name(index)
	match raw_name:
		"Sony DualSense", "PS5 Controller", "PS4 Controller", \
		"Nacon Revolution Unlimited Pro Controller":
			return GamepadType.PLAYSTATION
		"Switch":
			return GamepadType.NINTENDO

	# By default return xbox layout
	return GamepadType.XBOX
