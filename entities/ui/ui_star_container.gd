extends Node2D
class_name UIStarContainer

@onready var rays: Node2D = $Rays
@onready var star_circle: Sprite2D = $"Star-highlight-circle"
@onready var star: Sprite2D = $Star

@export var p1_star_1_container: Node2D
@export var p1_star_2_container: Node2D
@export var p2_star_1_container: Node2D
@export var p2_star_2_container: Node2D

func _ready():
	rays.modulate.a = 0.0
	star_circle.modulate.a = 0.0
	star.scale = Vector2.ZERO
	
	update_stars()	

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
	tween.tween_property(
		rays,
		"modulate:a",
		1.0,
		1.0
	)
	tween.parallel().tween_property(
		star_circle,
		"modulate:a",
		1.0,
		1.0
	)
	tween.parallel().tween_property(
		star,
		"scale",
		Vector2.ONE,
		1.0
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	tween.tween_interval(1.0)
	
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
	
	tween.tween_property(
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
