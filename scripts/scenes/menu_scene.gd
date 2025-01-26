extends Control
class_name MenuScene

@export var menu_song: AudioStream
@onready var offset: Node2D = $LogoContainer/Offset
var elapsed_time: float = 0
@onready var logo_serra: Sprite2D = $"LogoContainer/Offset/Logo-serra"


func _ready():
	GameController.reset()
	
	SoundController.change_bgm("menu", menu_song)

func _process(delta: float):
	if Input.is_action_just_pressed("p1_jump") or Input.is_action_just_pressed("p2_jump"):
		SceneTransition.change_scene(Constants.CHAR_SELECT_SCENE)
	
	if Input.is_action_just_pressed("p1_dash") or Input.is_action_just_pressed("p2_dash"):
		get_tree().quit()
	
	logo_serra.rotation_degrees += 300 * delta
	
	elapsed_time += delta
	var pos = sin(elapsed_time * 2) * 10
	offset.position.y = pos
