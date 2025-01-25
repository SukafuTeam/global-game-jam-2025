extends PlayerController
class_name TutorialBounceController

@export var showing: bool

func _ready():
	health = MAX_HEALTH
	
	data = Constants.get_character(0)
	
	body.texture = data.bubble_sprite
	character.texture = data.char_sprite
	looking_right = true
	tuto_animation()
	interactive = false

func tuto_animation():
	while true:
		await get_tree().create_timer(1.0).timeout
		showing = true
		SoundController.play_sfx(jump_sfx, 1.0, randf_range(0.8, 1.2))
		velocity.y -= JUMP_VELOCITY
		angular_velocity = calculate_rotation(20)
		body_container.scale = Vector2(0.7, 1.4)
		current_coyote_time = 0.0
		current_jump_buffer = 0.0
		await get_tree().create_timer(5.0).timeout
		showing = false
		await get_tree().create_timer(3.0).timeout

func _process(_delta: float):
	if velocity.y > 0.0 and showing:
		bashing = true
	
	if velocity.y > 1100:
		velocity.y = 1100
