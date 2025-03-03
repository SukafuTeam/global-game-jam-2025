extends Node

var camera: CameraController

var current_round: int = 1
var p1_index: int = -1
var p2_index: int = -1

var p1_victories: int = 0
var p2_victories: int = 0

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	reset()

func reset():
	current_round = 1
	p1_index = 0
	p2_index = 3
	p1_victories = 0
	p2_victories = 0


func _process(_delta: float):
	if Input.is_action_just_pressed("reset"):
		SceneTransition.change_scene(Constants.MENU_SCENE)

func add_camera_stress(stress: Vector2):
	if camera == null:
		return
	
	camera.add_stress(stress)

func hit_stop(time: float = 0.1):
	get_tree().paused = true
	await get_tree().create_timer(time).timeout
	get_tree().paused = false
