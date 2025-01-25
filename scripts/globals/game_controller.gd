extends Node

var camera: CameraController

func _ready():
	process_mode = PROCESS_MODE_ALWAYS

func add_camera_stress(stress: Vector2):
	if camera == null:
		return
	
	camera.add_stress(stress)

func hit_stop(time: float = 0.1):
	get_tree().paused = true
	await get_tree().create_timer(time).timeout
	get_tree().paused = false
