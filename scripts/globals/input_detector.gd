extends Node

signal input_changed(is_gamepad: bool)

enum GamepadType {XBOX, PLAYSTATION, NINTENDO}

# Input textures
var jump_textture_xbox: Texture2D
var jump_texture_playstation: Texture2D
var jump_texture_keyboard: Texture2D
var jump_texture_nintendo: Texture2D
var current_jump_texture: Texture2D:
	get:
		if !is_gamepad:
			return jump_texture_keyboard
		match current_gamepad_type:
			GamepadType.PLAYSTATION:
				return jump_texture_playstation
			GamepadType.NINTENDO:
				return jump_texture_nintendo
		return jump_textture_xbox

var is_gamepad: bool:
	set(value):
		if value == true and is_gamepad == false:
			# detect controller type everytime we change input to gamepad
			current_gamepad_type = detect_controller_type()
		var should_emit = false
		if value != is_gamepad:
			should_emit = true
		is_gamepad = value
		
		if should_emit:
			input_changed.emit(value)
	get:
		return is_gamepad
		
var current_gamepad_type: GamepadType

func _input(event):
	var move_input = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	if (event is InputEventKey) or (event is InputEventMouse):
		is_gamepad = false
	elif (event is InputEventJoypadButton) or move_input.length() > 0.1:
		is_gamepad = true

func detect_controller_type() -> GamepadType:
	var raw_name = Input.get_joy_name(0)
	
	match raw_name:
		"Sony DualSense", "PS5 Controller", "PS4 Controller", \
		"Nacon Revolution Unlimited Pro Controller":
			return GamepadType.PLAYSTATION
		"Switch":
			return GamepadType.NINTENDO

	# By default return xbox layout
	return GamepadType.XBOX