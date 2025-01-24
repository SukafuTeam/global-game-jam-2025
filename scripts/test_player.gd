extends Node2D

enum PLAYER {P1, P2}

@export var player: PLAYER

var right: bool:
	get:
		match player:
			PLAYER.P1:
				return Input.is_action_pressed("p1_right")
			PLAYER.P2:
				return Input.is_action_pressed("p2_right")
		return false

var left: bool:
	get:
		match player:
			PLAYER.P1:
				return Input.is_action_pressed("p1_left")
			PLAYER.P2:
				return Input.is_action_pressed("p2_left")
		return false

var up: bool:
	get:
		match player:
			PLAYER.P1:
				return Input.is_action_pressed("p1_up")
			PLAYER.P2:
				return Input.is_action_pressed("p2_up")
		return false

var down: bool:
	get:
		match player:
			PLAYER.P1:
				return Input.is_action_pressed("p1_down")
			PLAYER.P2:
				return Input.is_action_pressed("p2_down")
		return false

func _process(_delta: float):
	if right:
		position.x += 1
	if left:
		position.x -= 1
	if up:
		position.y -= 1
	if down:
		position.y += 1
