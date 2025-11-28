extends CharacterBody2D

# --- Movement variables ---
@export var speed: float = 350.0
@export var gravity: float = 1200.0
@export var acceleration: float = 0.2       # ground acceleration
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
@export var boost_multiplier: float = 1.5
var is_boosted: bool = false

# --- Jump helpers ---
var coyote_time = 0.15
var coyote_timer = 0.0
var jump_buffer_time = 0.15
var jump_buffer_timer = 0.0

func _physics_process(delta: float):
	apply_gravity(delta)
	handle_timers(delta)
	handle_input(delta)
	move_and_slide()
	update_animation()

# --- Apply gravity ---
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
	else:
		velocity.y = 0
		coyote_timer = coyote_time

# --- Handle dash and cooldown timers ---
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
	# Horizontal movement
	var input_axis = Input.get_action_strength("elf_right") - Input.get_action_strength("elf_left")
	var target_velocity = input_axis * speed

	var accel: float
	if is_on_floor():
		accel = acceleration
	else:
		accel = air_acceleration

	velocity.x = lerp(velocity.x, target_velocity, accel)

	# Jump buffering
	if Input.is_action_just_pressed("elf_jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# Execute jump if possible
	if jump_buffer_timer > 0 and coyote_timer > 0:
		if is_boosted:
			velocity.y = JUMP_VELOCITY * boost_multiplier
			is_boosted = false
		else:
			velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0

	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		start_dash()


func start_dash():
	is_dashing = true
	dash_timer = dash_duration
	dash_dir = sign(Input.get_axis("elf_left", "elf_right"))
	if dash_dir == 0:
		dash_dir = 1  

# --- Animation ---
func update_animation():
	var animated_sprite = $AnimatedSprite
	if not is_on_floor():
		animated_sprite.play("jump")
	elif abs(velocity.x) > 0.1:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")
