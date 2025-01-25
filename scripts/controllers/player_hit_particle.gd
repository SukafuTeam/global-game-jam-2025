extends Node2D

@onready var particle: CPUParticles2D = $Particle

func _ready() -> void:
	particle.emitting = true
	particle.finished.connect(queue_free)
