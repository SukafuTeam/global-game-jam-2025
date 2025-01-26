extends AnimatableBody2D
class_name CrusherController


@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var right_spike: Area2D = $RightSpike/Hurtbox
@onready var left_spike: Area2D = $LeftSpike/Hurtbox

func _ready():
	visible = false
	collision.disabled = true

func _physics_process(_delta: float):
	if visible == false:
		return
	
	for body in right_spike.get_overlapping_bodies():
		hurt_player(body)
	for body in left_spike.get_overlapping_bodies():
		hurt_player(body)

func set_active():
	visible = true
	collision.disabled = false
	
func hurt_player(other: Node2D):
	if !(other is PlayerController):
		return
	
	if visible == false:
		return
	
	var p = other as PlayerController
	p.collide_with_deadly(self)
