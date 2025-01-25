class_name CameraController
extends Camera2D

@export var max_offset : Vector2 = Vector2(20.0, 20.0)
@export var shakeReduction : float = 0.9
@export var noise: FastNoiseLite

var elapsed_time: float = 0.0
var stress : Vector2 = Vector2.ZERO

func _ready():
	GameController.camera = self

func _process(delta):
	elapsed_time += delta
	
	if noise == null:
		push_warning("No noise configured")
		return
	
	#var n_value = noise.get_noise_1d(elapsed_time)
	var n_value = get_shake()
	var shake = stress * stress
	
	offset = Vector2.ZERO
	offset.x = (max_offset.x * shake.x * n_value)
	offset.y = (max_offset.y * shake.y * n_value)
	
	stress *= shakeReduction
	if stress.length() < 0.01:
		stress = Vector2.ZERO

func get_shake() -> float:
	return sin(elapsed_time * 300.0)

# Ref
#func _get_noise(noise_seed) -> FastNoiseLite:
	#var n = FastNoiseLite.new()
	#n.noise_type = FastNoiseLite.TYPE_PERLIN
	#n.seed = noise_seed
	#n.fractal_octaves = 4
	#n.frequency = 0.1
	#return n

func add_stress(amount: Vector2):
	stress += amount
	if stress.length() > 1.0:
		stress = stress.normalized()
