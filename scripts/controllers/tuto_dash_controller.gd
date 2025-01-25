extends PlayerController
class_name TutorialDashController

@export var showing: bool

func _ready():
	health = MAX_HEALTH
	data = Constants.get_character(1)
	body.texture = data.bubble_sprite
	character.texture = data.char_sprite
	looking_right = true
	tuto_animation()
	interactive = false
	
func tuto_animation():
	while true:
		await get_tree().create_timer(1.2).timeout
		looking_right = true
		SoundController.play_sfx(jump_sfx, 1.0, randf_range(0.8, 1.2))
		velocity.y -= JUMP_VELOCITY
		angular_velocity = calculate_rotation(20)
		body_container.scale = Vector2(0.7, 1.4)
		current_coyote_time = 0.0
		current_jump_buffer = 0.0
		showing = true
		await get_tree().create_timer(3.0).timeout
		looking_right = false
		SoundController.play_sfx(jump_sfx, 1.0, randf_range(0.8, 1.2))
		velocity.y -= JUMP_VELOCITY
		angular_velocity = calculate_rotation(20)
		body_container.scale = Vector2(0.7, 1.4)
		current_coyote_time = 0.0
		current_jump_buffer = 0.0
		showing = true
		await get_tree().create_timer(3.0).timeout

func _process(_delta: float) -> void:
	if velocity.y > 0.0 and showing:
		velocity.x += AIR_SPIN_DASH_GAIN if looking_right else -AIR_SPIN_DASH_GAIN
		velocity.y = -AIR_SPIN_JUMP
		angular_velocity = calculate_rotation(10)
		can_dash = false
		bashing = false
		body_container.scale = Vector2(1.5, 0.5)
		SoundController.play_sfx(dash_sfx, 1.0, randf_range(0.9, 1.1))
		showing = false
		var particle = dash_particle.instantiate() as Node2D
		add_child(particle)
		particle.global_rotation_degrees = 180 if looking_right else 0

func process_air(delta: float) -> State:
	
	hor_move_player(delta, AIR_HOR_ACCEL, AIR_FRICTION * 6)
	
	bounce_on_wall()
	
	if is_on_floor():
		angular_velocity = calculate_rotation(30.0)
		
		if last_velocity.y > 400.0:
			SoundController.play_sfx(bounce_sfx, 0.8, randf_range(0.8, 1.2))
			var bounce_force = last_velocity.length() * 0.3
			var bounce_direction = -get_floor_normal()
			velocity -= bounce_force * bounce_direction
			body_container.scale = Vector2(0.8, 1.2)
			current_coyote_time = COYOTE_TIME
			can_dash = true
			bashing = false
			
			var hit = hit_particle.instantiate() as Node2D
			add_child(hit)
			hit.global_rotation = get_floor_normal().angle()
			
			return State.AIR
		
		return State.GROUND
	
	return State.AIR
