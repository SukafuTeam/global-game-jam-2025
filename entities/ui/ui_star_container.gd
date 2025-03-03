extends Node2D
class_name UIStarContainer

@onready var rays: Node2D = $Rays
@onready var star_circle: Sprite2D = $"Star-highlight-circle"
@onready var star: Sprite2D = $Star

@export var p1_star_1_container: Node2D
@export var p1_star_2_container: Node2D
@export var p2_star_1_container: Node2D
@export var p2_star_2_container: Node2D

@export var star_sfx: AudioStream
@export var move_sfx: AudioStream

func _ready():
	rays.modulate.a = 0.0
	star_circle.modulate.a = 0.0
	star.scale = Vector2.ZERO
	
	update_stars()
	star_animation()

func star_animation():
	var tween = create_tween()
	tween.set_loops(-1)
	for ui_star in [p1_star_2_container, p1_star_1_container, p2_star_1_container, p2_star_2_container]:
		tween.tween_property(
			ui_star,
			"scale",
			Vector2.ONE * 1.2,
			0.2
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(
			ui_star,
			"scale",
			Vector2.ONE,
			0.2
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _process(delta: float):
	rays.rotation_degrees += 10 * delta

func update_stars():
	p1_star_1_container.visible = GameController.p1_victories >= 1
	p1_star_2_container.visible = GameController.p1_victories >= 2
	p2_star_1_container.visible = GameController.p2_victories >= 1
	p2_star_2_container.visible = GameController.p2_victories >= 2

func final_sequence(winner: InputController.PLAYER):
	var tween = create_tween()
	
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		SoundController.play_sfx(star_sfx)
	)
	tween.tween_property(
		rays,
		"modulate:a",
		1.0,
		0.5
	)
	tween.parallel().tween_property(
		star_circle,
		"modulate:a",
		1.0,
		0.5
	)
	tween.parallel().tween_property(
		star,
		"scale",
		Vector2.ONE,
		0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	tween.tween_interval(0.5)
	
	var target_pos: Vector2
	match winner:
		InputController.PLAYER.P1:
			if GameController.p1_victories == 0:
				target_pos = p1_star_1_container.global_position
			else:
				target_pos = p1_star_2_container.global_position
			GameController.p1_victories += 1
		InputController.PLAYER.P2:
			if GameController.p2_victories == 0:
				target_pos = p2_star_1_container.global_position
			else:
				target_pos = p2_star_2_container.global_position
			GameController.p2_victories += 1
	
	tween.tween_property(
		rays,
		"modulate:a",
		0.0,
		0.4
	)
	tween.parallel().tween_property(
		star_circle,
		"modulate:a",
		0.0,
		0.4
	)
	
	tween.tween_callback(func():
		SoundController.play_sfx(move_sfx)
	).set_delay(0.3)
	tween.parallel().tween_property(
		star,
		"global_position",
		target_pos,
		0.5
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(
		star,
		"scale",
		Vector2.ONE * 0.12,
		0.5
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC
	)
	await tween.finished
	
	update_stars()

func get_stars(p: InputController.PLAYER) -> Array[Node2D]:
	if p == InputController.PLAYER.P1:
		return [
			p1_star_1_container.get_child(0),
			p1_star_2_container.get_child(0),
		]
	
	return [
			p2_star_1_container.get_child(0),
			p2_star_2_container.get_child(0),
		]
