extends CharacterBody2D

# --- Movement variables ---
@export var speed: float = 350.0
@export var gravity: float = 1200.0
@export var acceleration: float = 0.2
@export var air_acceleration: float = 0.05
const JUMP_VELOCITY = -450.0

# --- Dash variables ---
@export var dash_speed = 800.0
@export var dash_duration = 0.15
@export var dash_cooldown = 0.4
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_dir: int = 0
var dash_cooldown_timer: float = 0.0

# --- Boost variables ---
@export var boost_multiplier: float = 1.75
var is_boosted: bool = false

# --- Jump helpers ---
var coyote_time = 0.15
var coyote_timer = 0.0
var jump_buffer_time = 0.15
var jump_buffer_timer = 0.0

# --- SFX ---
var jump_sfx = preload("res://sounds/alfen/jump.mp3")
var boost_jump_sfx = preload("res://sounds/alfen/boostSFX.mp3")   # << NEW SOUND
var dash_sfx_list = [
	preload("res://sounds/alfen/swoosh01.mp3"),
	preload("res://sounds/alfen/swoosh02.mp3")
]
var footstep_sfx = preload("res://sounds/alfen/walk.mp3")
var footstep_timer = 0.0
@export var footstep_interval = 0.3

func _physics_process(delta: float):
	apply_gravity(delta)
	handle_timers(delta)
	handle_input(delta)
	handle_footsteps(delta)
	move_and_slide()
	update_animation()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
	else:
		velocity.y = 0
		coyote_timer = coyote_time

# --- Handle dash cooldown ---
func handle_timers(delta):
	if dash_cooldown_timer > 0:
		dash_cooldown_timer = max(0, dash_cooldown_timer - delta)

	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_dir * dash_speed
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown

# --- Input handling ---
func handle_input(delta):
	var input_axis = Input.get_action_strength("elf_right") - Input.get_action_strength("elf_left")
	var target_velocity = input_axis * speed

	var accel: float = acceleration if is_on_floor() else air_acceleration
	velocity.x = lerp(velocity.x, target_velocity, accel)

	# Jump buffer
	if Input.is_action_just_pressed("elf_jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	if jump_buffer_timer > 0 and coyote_timer > 0:
		if is_boosted:
			velocity.y = JUMP_VELOCITY * boost_multiplier
			is_boosted = false
			play_boost_jump_sound() 
		else:
			velocity.y = JUMP_VELOCITY
			play_jump_sound()

		jump_buffer_timer = 0
		coyote_timer = 0

	# Dash
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		start_dash()
		play_dash_sound()

func start_dash():
	is_dashing = true
	dash_timer = dash_duration
	dash_dir = sign(Input.get_axis("elf_left", "elf_right"))
	if dash_dir == 0:
		dash_dir = 1

# --- Footsteps ---
func handle_footsteps(delta):
	if is_on_floor() and abs(velocity.x) > 0.1:
		var step_interval = footstep_interval / (abs(velocity.x) / speed)
		footstep_timer -= delta

		if footstep_timer <= 0:
			$FootstepSFX.stream = footstep_sfx
			$FootstepSFX.pitch_scale = lerp(1.0, 1.5, abs(velocity.x) / speed)
			$FootstepSFX.play()
			footstep_timer = step_interval
	else:
		if $FootstepSFX.playing:
			$FootstepSFX.stop()
		footstep_timer = 0


func play_jump_sound():
	$JumpSFX.stream = jump_sfx
	$JumpSFX.play()

func play_boost_jump_sound():       
	$JumpSFX.stream = boost_jump_sfx
	$JumpSFX.play()

func play_dash_sound():
	$DashSFX.stream = dash_sfx_list[randi() % dash_sfx_list.size()]
	$DashSFX.play()


func update_animation():
	var animated_sprite = $AnimatedSprite
	if not is_on_floor():
		animated_sprite.play("jump")
	elif abs(velocity.x) > 0.1:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")
