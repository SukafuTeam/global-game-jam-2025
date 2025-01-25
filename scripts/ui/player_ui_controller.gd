extends Node2D
class_name PlayerUIController

const SPEED_THRESHOLD: float = 2000.0
const SPEED_SHAKE_AMOUNT: Vector2 = Vector2(10.0, 10.0)

@onready var portrait: TextureRect = $PortraitMask/Portrait
var portrait_origin_pos: Vector2

@export var hearts: Array[UIHeartController] = []
@export var open_time: Vector2 = Vector2(2.0, 4.0)
@export var closed_time: Vector2 = Vector2(0.1, 0.2)
var blink_time: float
var is_open

@export var player: PlayerController

func _ready():
	portrait_origin_pos = portrait.position
	is_open = true
	blink_time = randf_range(open_time.x, open_time.y)
	

func _process(delta: float):
	if player == null:
		return
	
	portrait.position = portrait_origin_pos
	
	if player.current_iframe_time > 0.0:
		portrait.texture = player.data.damage_portrait
		return
	
	if player.velocity.length() > SPEED_THRESHOLD:
		portrait.texture = player.data.speed_portrait
		portrait.position += Vector2(
			randf_range(-SPEED_SHAKE_AMOUNT.x, SPEED_SHAKE_AMOUNT.x),
			randf_range(-SPEED_SHAKE_AMOUNT.y, SPEED_SHAKE_AMOUNT.y)
		)
		return
	
	blink_time -= delta
	
	if blink_time <= 0.0:
		is_open = !is_open
		if is_open:
			blink_time = randf_range(open_time.x, open_time.y)
		else:
			blink_time = randf_range(closed_time.x, closed_time.y)
		
	portrait.texture = player.data.idle_portrait if is_open else player.data.blink_portrait

func take_damage(new_health: int):
	for i in range(hearts.size()):
		if hearts[i].full:
			if new_health <= i:
				hearts[i].set_empty()
	
	
