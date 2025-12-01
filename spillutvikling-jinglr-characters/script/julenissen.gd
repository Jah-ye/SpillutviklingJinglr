extends CharacterBody2D

# --- Movement variables ---
@export var speed: float = 250.0
@export var gravity: float = 1200.0
@export var acceleration: float = 0.1 
@export var air_acceleration: float = 0.03
const JUMP_VELOCITY = -300.0

# --- Jump helpers ---
var coyote_time = 0.1
var coyote_timer = 0.0
var jump_buffer_time = 0.1
var jump_buffer_timer = 0.0


var footstep_sfx = preload("res://sounds/julenissen/footsteps.mp3")
var footstep_timer = 0.0
@export var footstep_interval = 0.35 

var jump_sfx = preload("res://sounds/julenissen/jump.mp3")

func _physics_process(delta: float):
	apply_gravity(delta)
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

# --- Input handling ---
func handle_input(delta):
	var input_axis = Input.get_action_strength("santa_right") - Input.get_action_strength("santa_left")
	var target_velocity = input_axis * speed
	var accel = acceleration if is_on_floor() else air_acceleration
	velocity.x = lerp(velocity.x, target_velocity, accel)

	# Jump buffering
	if Input.is_action_just_pressed("santa_jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
		play_jump_sound()

# --- Footsteps SFX ---
func handle_footsteps(delta):
	if is_on_floor() and abs(velocity.x) > 0.1:
		var step_interval = footstep_interval / (abs(velocity.x) / speed)
		footstep_timer -= delta
		if footstep_timer <= 0:
			$FootstepsSFX.stream = footstep_sfx
			# Lower pitch for heavy character
			$FootstepsSFX.pitch_scale = lerp(0.8, 1.0, abs(velocity.x) / speed)
			$FootstepsSFX.play()
			footstep_timer = step_interval
	else:
		if $FootstepsSFX.playing:
			$FootstepsSFX.stop()
		footstep_timer = 0

# --- Jump SFX ---
func play_jump_sound():
	$JumpSFX.stream = jump_sfx
	$JumpSFX.play()

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
