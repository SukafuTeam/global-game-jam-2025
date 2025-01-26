extends CharacterBody2D
class_name PlayerController

signal took_damage(new_health: int)
signal died

#const BALL_SIZE: float = 32.0
const BALL_SIZE: float = 56.0

const MAX_HEALTH: int = 3
const IFRAME_TIME: float = 2.0

const MAX_MOVE_SPEED: float = 1125.0
const MAX_VELOCITY: float = 4000.0
const GROUND_HOR_ACCEL: float = 1350.0
const AIR_HOR_ACCEL: float = 1125.0
const GROUND_FRICTION: float = 399.0
const AIR_FRICTION: float = 150.0

const JUMP_VELOCITY: float = 650.0
const GRAVITY_DOWN_MODIFIER: float = 1.3
const BASH_DOWN_MODIFIER: float = 5.0

const AIR_SPIN_DASH_GAIN: float = 900.0
const AIR_SPIN_JUMP: float = 225.0

const COYOTE_TIME: float = 0.2
const JUMP_BUFFER_TIME: float = 0.1

const CHAR_MAX_ANGLE: float = 45
const CHAR_MAX_SPEED: float = 200.0

enum State {
	GROUND,
	AIR
}

@onready var body_container: Node2D = $BodyContainer
@onready var body: Sprite2D = $BodyContainer/Body
@onready var character: Sprite2D = $BodyContainer/Character
@onready var bash_ray = $BashRay
@onready var ball_area: Area2D = $BallArea
@onready var hitbox_area: Area2D = $HitBox
@onready var player_label: Label = $PlayerLabel

@export_subgroup("Configuration")
@export var interactive: bool
@export var player: InputController.PLAYER
@export var data: CharacterData
@export var frozen: bool

@export_subgroup("Game")
@export var health: int
@export var collided_this_frame: bool
@export var current_coyote_time: float
@export var current_jump_buffer: float
@export var current_iframe_time: float

@export_subgroup("Particles")
@export var hit_particle: PackedScene
@export var player_particle: PackedScene
@export var ricochet_particle: PackedScene
@export var dash_particle: PackedScene
@export var damage_particle: PackedScene

@export_subgroup("Sfx")
@onready var bash_player: AudioStreamPlayer = $BashPlayer
@export var jump_sfx: AudioStream
@export var bounce_sfx: AudioStream
@export var punch_sfx: AudioStream
@export var ricochet_sfx: AudioStream
@export var damage_sfx: AudioStream
@export var dash_sfx: AudioStream
@export var shake_sfx: AudioStream

@export var state: State = State.GROUND:
	set(value):
		if value != state:
			exit_state(state)
			enter_state(value)
		state = value
	get:
		return state
var looking_right: bool

var bashing: bool = false:
	set(value):
		if value == false:
			if bash_player.playing:
				bash_player.stop()
		else:
			bash_player.play()
		bashing = value
	get:
		return bashing
var can_dash: bool = false
var angular_velocity: float = 0.0
var last_velocity: Vector2 = Vector2.ZERO


func _ready():
	health = MAX_HEALTH
	ball_area.body_entered.connect(collide_with_ball)
	hitbox_area.area_entered.connect(collide_with_deadly)
	
	data = Constants.get_character(randi_range(0, 4))
	
	body.texture = data.bubble_sprite
	character.texture = data.char_sprite
	can_dash = true
	if player == InputController.PLAYER.P1:
		looking_right = true
	
	player_label.text = "P1" if player == InputController.PLAYER.P1 else "P2"
	player_label.add_theme_color_override(
		"font_color",
		Constants.p1_color if player == InputController.PLAYER.P1 else Constants.p2_color
	)
	
	var tween = player_label.create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(player_label, "modulate:a", 0.0, 2.0)

func _process(delta: float):
	if current_iframe_time > 0.0:
		body.modulate.a = 0.3
	else:
		body.modulate.a = 1.0
	character.flip_h = !looking_right
	var hor_input = Input.get_axis(InputController.get_left(player), InputController.get_right(player))
	
	if interactive:
		if abs(hor_input) < 0.1:
			character.rotation = lerp_angle(character.rotation, 0.0, 5 * delta)
	else:
		character.rotation = lerp_angle(character.rotation, 0.0, 5 * delta)

func _physics_process(delta):
	if frozen:
		velocity = Vector2.ZERO
		return
	
	collided_this_frame = false
	if not is_on_floor():
		var gravity = get_gravity()
		if velocity.y > 0:
			gravity *= GRAVITY_DOWN_MODIFIER
		if bashing:
			gravity *= BASH_DOWN_MODIFIER
		
		velocity += gravity * delta
	
	current_coyote_time -= delta
	current_jump_buffer -= delta
	current_iframe_time -= delta
	
	if is_on_floor():
		current_coyote_time = COYOTE_TIME
		
	if Input.is_action_just_pressed(InputController.get_jump(player)):
		current_jump_buffer = JUMP_BUFFER_TIME
	
	match state:
		State.GROUND:
			state = process_ground(delta)
		State.AIR:
			state = process_air(delta)
			
	body.rotation_degrees += angular_velocity * delta
	character.rotation_degrees += angular_velocity * 0.5 * delta

	last_velocity = velocity
	
	body_container.scale = body_container.scale.move_toward(Vector2.ONE, 1 * delta)
	
	for overlapping_body in ball_area.get_overlapping_bodies():
		if overlapping_body != self:
			push_players_apart(overlapping_body as PlayerController)
	
	if velocity.length() > MAX_VELOCITY:
		velocity = velocity.normalized() * MAX_VELOCITY
	
	move_and_slide()
	

func process_ground(delta) -> State:
	
	if !Input.is_action_pressed(InputController.get_down(player)):
		hor_move_player(delta, GROUND_HOR_ACCEL, GROUND_FRICTION)
	
	angular_velocity = calculate_rotation()
	
	if interactive:
		if current_jump_buffer > 0.0 and current_coyote_time > 0.0:
			SoundController.play_sfx(jump_sfx, 1.0, randf_range(0.8, 1.2))
			velocity.y -= JUMP_VELOCITY
			angular_velocity = calculate_rotation(20)
			body_container.scale = Vector2(0.7, 1.4)
			current_coyote_time = 0.0
			current_jump_buffer = 0.0
			return State.AIR
		
	bounce_on_wall()
	
	if current_coyote_time <= 0.0:
		return State.AIR
	
	return State.GROUND

func process_air(delta: float) -> State:
	
	hor_move_player(delta, AIR_HOR_ACCEL, AIR_FRICTION)
	
	if interactive:
		var hor_input = Input.get_axis(InputController.get_left(player), InputController.get_right(player))
		if Input.is_action_just_pressed(InputController.get_jump(player)) and !bash_ray.is_colliding():
			#SoundController.play_sfx(bash_sfx, 1.0)
			bashing = true
			
		if Input.is_action_just_pressed(InputController.get_dash(player)) and can_dash and abs(hor_input) > 0.2:
			velocity.x += AIR_SPIN_DASH_GAIN if looking_right else -AIR_SPIN_DASH_GAIN
			velocity.y = -AIR_SPIN_JUMP
			angular_velocity = calculate_rotation(10)
			can_dash = false
			bashing = false
			body_container.scale = Vector2(1.5, 0.5)
			SoundController.play_sfx(dash_sfx, 1.0, randf_range(0.9, 1.1))
			
			var particle = dash_particle.instantiate() as Node2D
			add_child(particle)
			particle.global_rotation_degrees = 180 if hor_input > 0.0 else 0
		
	if bashing:
		body_container.scale = Vector2(1.3, 0.6)
	
	bounce_on_wall()
	
	if is_on_floor():
		angular_velocity = calculate_rotation(30.0)
		if bashing:
			SoundController.play_sfx(shake_sfx, 1.0, randf_range(0.8, 1.2))
			var bounce_force = min(last_velocity.length() * 0.7, 1200)
			var bounce_direction = -get_floor_normal()
			velocity -= bounce_force * bounce_direction
			bashing = false
			body_container.scale = Vector2(0.6, 1.3)
			can_dash = true
			
			var vertical_speed = inverse_lerp(0.0, 1200, last_velocity.length())
			var camera_stress = lerp(0.0, 0.5, vertical_speed)
			camera_stress = clamp(camera_stress, 0.0, 0.5)
			GameController.add_camera_stress(Vector2(0.0, camera_stress))
			
			var hit = hit_particle.instantiate() as Node2D
			add_child(hit)
			hit.global_rotation = get_floor_normal().angle()
			
			return State.AIR
		
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
	
	if current_jump_buffer > 0.0 and current_coyote_time > 0.0:
		SoundController.play_sfx(jump_sfx, 1.0, randf_range(0.8, 1.2))
		velocity.y -= JUMP_VELOCITY
		angular_velocity = calculate_rotation(20)
		body_container.scale = Vector2(0.7, 1.4)
		current_coyote_time = 0.0
		current_jump_buffer = 0.0
	
	return State.AIR

func hor_move_player(delta: float, accel: float, friction: float):
	var hor_input = Input.get_axis(InputController.get_left(player), InputController.get_right(player))
	
	if !interactive:
		hor_input = 0.0
	
	var hor_accel = hor_input * accel * delta
	
	if hor_input > 0.1:
		looking_right = true
	if hor_input < -0.1:
		looking_right = false
	
	# We only want to ADD to the velocity if we are under the max move speed
	if abs(velocity.x) < MAX_MOVE_SPEED:
		velocity.x += hor_accel
	
	# We only want to decelerate the player if not input is being pressed
	if abs(hor_input) < 0.1:
		velocity.x = move_toward_snap(velocity.x, 0.0, friction * delta)

func bounce_on_wall():
	if is_on_wall():
		var normalized_wall = get_wall_normal().normalized()
		var dot_product = last_velocity.dot(normalized_wall)
		var reflected_velocity = last_velocity - 2.0 * dot_product * normalized_wall
		velocity = reflected_velocity * 0.7
		if abs(velocity.x) > 200.0:
			SoundController.play_sfx(bounce_sfx, 0.8, randf_range(0.8, 1.2))
			body_container.scale = Vector2(0.7, 1.2)
			
			var velocity_percent = inverse_lerp(0.0, 1500.0, abs(velocity.x))
			var stress_amount = lerp(0.0, 1.0, velocity_percent)
			stress_amount = clamp(stress_amount, 0.0, 1.0)
			GameController.add_camera_stress(Vector2(stress_amount, 0.0))
			
			var hit = hit_particle.instantiate() as Node2D
			add_child(hit)
			hit.global_rotation = normalized_wall.angle()

func collide_with_ball(other_body: Node2D):
	if !(other_body is PlayerController):
		return
	
	if other_body == self:
		return
		
	var other = other_body as PlayerController
	if collided_this_frame or other.collided_this_frame:
		return
		
	if bashing:
		bashing = false
	if other.bashing:
		other.bashing = false
	
	 # Collision normal (direction from one ball to the other
	var normal = (other.global_position - global_position).normalized()
	var other_normal = normal # By default, both use the same normal
	
	if last_velocity.length() > 400.0 or other.last_velocity.length() > 400.0:
		
		if (last_velocity.length() + other.last_velocity.length()) > 2200.0:
			GameController.hit_stop(0.3)
			SoundController.play_sfx(ricochet_sfx)
			var particle = ricochet_particle.instantiate() as Node2D
			add_sibling(particle)
			particle.global_rotation = normal.angle()
			particle.global_position = global_position
		else:
			SoundController.play_sfx(punch_sfx, 1.0, randf_range(0.9, 1.1))
			var particle = player_particle.instantiate() as Node2D
			add_sibling(particle)
			particle.global_position = global_position
			particle.global_rotation = normal.angle()
		
	
	# If either ball is grounded, we want to transfer all energy to be horizontal (slipping motion)
	if current_coyote_time > 0.0:
		normal.y = 0
		normal = normal.normalized()
	if other.current_coyote_time > 0.0:
		other_normal.y = 0
		other_normal = other_normal.normalized()
	
	# Velocity components along the normal
	var vel_self_normal = normal.dot(last_velocity)
	var vel_other_normal = other_normal.dot(other.last_velocity)
	
	# Exchange the normal components of velocity
	var new_self_normal = vel_other_normal * normal
	var new_other_normal = vel_self_normal * other_normal
	
	# Tangent component (unchanged during collision)
	var vel_self_tangent = last_velocity - vel_self_normal * normal
	var vel_other_tangent = other.last_velocity - vel_other_normal * other_normal
	
	# Add some self-returning force for a bounce feeling
	var self_bounce = 0.4 * vel_self_normal * normal
	var other_bounce = 0.4 * vel_other_normal * other_normal
	
	# Update velocity for self and mark it as collided this frame
	velocity = vel_self_tangent + new_self_normal - self_bounce
	collided_this_frame = true
	
	# Update velocity for the other ball, also marking as collided
	other.velocity = vel_other_tangent + new_other_normal - other_bounce
	other.collided_this_frame = true
	
func collide_with_deadly(_other_area: Node2D):
	if current_iframe_time > 0.0:
		return
	
	var particle = damage_particle.instantiate() as Node2D
	add_sibling(particle)
	particle.global_position = global_position
	
	GameController.add_camera_stress(Vector2.ONE)
	
	health -= 1
	took_damage.emit(health)
	velocity = Vector2.ZERO
	SoundController.play_sfx(damage_sfx, 1.0, data.damage_pitch_scale)
	current_iframe_time = IFRAME_TIME
	
	if health == 0:
		died.emit()
		body.visible = false
		character.visible = false
		return
	
	GameController.hit_stop(0.3)
	


func push_players_apart(other: PlayerController):
	var dist = other.global_position - global_position
	var overlap = BALL_SIZE * 2 - dist.length()
	
	if overlap < 0.0:
		return
	
	var direction = dist.normalized()
	
	# Push both balls out by half the overlap distance
	global_position -= direction * (overlap / 2)
	other.global_position += direction * (overlap / 2)
	
	velocity -= direction.normalized() * 100.0
	other.velocity += direction.normalized() * 100.0

func move_toward_snap(from: float, to: float, delta: float) -> float:
	if abs((to - from)) - delta < 0.01:
		return to
	return move_toward(from, to, delta)

func move_toward_snap_2(from: Vector2, to: Vector2, delta: float) -> Vector2:
	if (to - from).length() <= delta:
		return to
	return from.move_toward(to, delta)

func calculate_rotation(radius: float = 30.0, hor_speed: float = 0.0) -> float:
	var circumference = 2 * PI * radius
	if hor_speed == 0.0:
		hor_speed = velocity.x
	var rotations_per_second = hor_speed / circumference
	
	# Convert rotations to degrees per second (so we can use this * delta)
	var degrees_per_second = rotations_per_second * 360
	return degrees_per_second

func exit_state(old_state: State):
	match old_state:
		State.GROUND:
			pass
		State.AIR:
			pass

func enter_state(new_state: State):
	match new_state:
		State.GROUND:
			can_dash = true
		State.AIR:
			bashing = false
			can_dash = true
