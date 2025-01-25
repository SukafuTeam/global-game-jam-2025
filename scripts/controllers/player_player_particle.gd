extends Node2D

@onready var up_particle: CPUParticles2D = $UpParticle
@onready var down_particle: CPUParticles2D = $DownParticle


func _ready() -> void:
	up_particle.emitting = true
	down_particle.emitting = true
	up_particle.finished.connect(queue_free)
