extends Node

enum PLAYER {
	P1,
	P2
}

func get_right(player: PLAYER) -> String:
	match player:
		PLAYER.P1:
			return "p1_right"
		PLAYER.P2:
			return "p2_right"
	
	return ""

func get_left(player: PLAYER) -> String:
	match player:
		PLAYER.P1:
			return "p1_left"
		PLAYER.P2:
			return "p2_left"
	
	return ""

func get_jump(player: PLAYER) -> String:
	match player:
		PLAYER.P1:
			return "p1_jump"
		PLAYER.P2:
			return "p2_jump"
	
	return ""

func get_dash(player: PLAYER) -> String:
	match player:
		PLAYER.P1:
			return "p1_dash"
		PLAYER.P2:
			return "p2_dash"
	
	return ""

func start_joy_vibration(player: PLAYER, duration: float):
	var index = 0 if player == PLAYER.P1 else 1
	if Input.get_connected_joypads().size() - 1 < index:
		return
	
	Input.start_joy_vibration(index, 2000, 1000, duration)
	
