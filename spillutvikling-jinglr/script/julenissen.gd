extends CharacterBody2D

# --- Movement variables ---
@export var speed: float = 250.0
@export var gravity: float = 1200.0
@export var acceleration: float = 0.1      # slightly higher to reduce sliding
@export var air_acceleration: float = 0.05
const JUMP_VELOCITY = -300.0

func _physics_process(delta: float):
	handle_input(delta)
	apply_gravity(delta)
	move_and_slide()
	update_animation()

# --- Input handling ---
func handle_input(delta):
	var input_axis = Input.get_action_strength("santa_right") - Input.get_action_strength("santa_left")
	var target_velocity = input_axis * speed

	var accel: float
	if is_on_floor():
		accel = acceleration
	else:
		accel = air_acceleration

	# Smooth horizontal movement
	if input_axis != 0:
		velocity.x = lerp(velocity.x, target_velocity, accel)
	else:
		# Stop immediately when no input (reduces sliding)
		velocity.x = 0

	# Jump
	if Input.is_action_just_pressed("santa_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

# --- Gravity ---
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

# --- Animation ---
func update_animation():
	var animated_sprite = $AnimatedSprite2D
	if not is_on_floor():
		animated_sprite.play("jump")
	elif abs(velocity.x) > 0.1:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")

# Boost signals
func _on_BoostZone_body_entered(body):
	if body.is_in_group("SmallCharacter"):
		body.is_boosted = true

func _on_BoostZone_body_exited(body):
	if body.is_in_group("SmallCharacter"):
		body.is_boosted = false
