extends Area2D
class_name SpringController


@export var jump_force: Vector2 = Vector2(0, -1000)
@export var bounce_sfx: AudioStream
@onready var body: Node2D = $BodyContainer

var bounce_tween: Tween

func _ready():
	body_entered.connect(player_entered)

func player_entered(other: Node2D):
	if !(other is PlayerController):
		return
	
	var p = other as PlayerController
	if p.bashing:
		p.bashing = false
		p.velocity = jump_force * 1.5
	else:
		p.velocity = jump_force
	bounce()
	SoundController.play_sfx(bounce_sfx)

func bounce():
	if bounce_tween:
		bounce_tween.kill()
	
	bounce_tween = create_tween()
	bounce_tween.tween_property(
		body,
		"scale",
		Vector2(1.2, 0.8),
		0.05,
	).set_trans(Tween.TRANS_ELASTIC)
	bounce_tween.tween_property(
		body,
		"scale",
		Vector2(0.9, 1.6),
		0.05,
	).set_trans(Tween.TRANS_SPRING)
	bounce_tween.tween_property(
		body,
		"scale",
		Vector2.ONE,
		0.1,
	).set_trans(Tween.TRANS_SPRING)
