extends CharacterBody2D

# Movement variabler
@export var speed: float = 350.0 
@export var gravity: float = 1200.0 
@export var acceleration: float = 0.2 
@export var air_acceleration: float = 0.05 # Akselerasjon i lufta
const JUMP_VELOCITY = -450.0 

# Dash variabler
@export var dash_speed = 800.0
@export var dash_duration = 0.15 
@export var dash_cooldown = 0.4 # tid før neste dash kan brukes.
var is_dashing: bool = false # Holder styr på om spilleren akkurat nå er i en dash
var dash_timer: float = 0.0  # Timer for dash-varighet
var dash_dir: int = 0  # Retningen man dasher
var dash_cooldown_timer: float = 0.0 # Teller ned cooldown

# Boost variabler
@export var boost_multiplier: float = 1.75 # Hvor mye sterkere boost-hopp er
var is_boosted: bool = false # Om spilleren har boost aktivert

# Jump helpers
var coyote_time = 0.15 # Liten tid man kan hoppe etter kanten
var coyote_timer = 0.0 # Teller ned coyote time

# SFX
var jump_sfx = preload("res://sounds/alfen/jump.mp3") # Vanlig hopp-lyd
var boost_jump_sfx = preload("res://sounds/alfen/boostSFX.mp3")  # Boost-hopp lyd
var dash_sfx_list = [  # Liste med dash-lyder
	preload("res://sounds/alfen/swoosh01.mp3"),
	preload("res://sounds/alfen/swoosh02.mp3")
]
var footstep_sfx = preload("res://sounds/alfen/walk.mp3") # Fotsteg lyd
var footstep_timer = 0.0 # Timer mellom fotsteg
@export var footstep_interval = 0.3 # Standard intervall

func _physics_process(delta: float):
	apply_gravity(delta) # Legger på tyngdekraft
	handle_timers(delta) # Oppdaterer dash- og cooldown-timere
	handle_input(delta)  # Leser input fra spilleren
	handle_footsteps(delta) # Spiller gå-lyder
	move_and_slide() # Beveger spilleren i verden
	update_animation() # Oppdaterer animasjonen

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta # Fall når ikke på bakken
		coyote_timer -= delta # Coyote time teller ned
	else:
		velocity.y = 0  # Nullstill fart på bakken
		coyote_timer = coyote_time # Reset coyote time

# dash cooldown 
func handle_timers(delta):
	if dash_cooldown_timer > 0:
		dash_cooldown_timer = max(0, dash_cooldown_timer - delta) # Cooldown teller ned

	if is_dashing:
		dash_timer -= delta  # Dash varer kort tid
		velocity.x = dash_dir * dash_speed # Beveg i dash-retningen
		if dash_timer <= 0:
			is_dashing = false # Dash ferdig
			dash_cooldown_timer = dash_cooldown

# Input handling
func handle_input(_delta):
	var input_axis = Input.get_action_strength("elf_right") - Input.get_action_strength("elf_left")  # Bevegelsesinput
	var target_velocity = input_axis * speed # Ønsket fart

	var accel: float = acceleration if is_on_floor() else air_acceleration # Velg riktig akselerasjon
	velocity.x = lerp(velocity.x, target_velocity, accel) # Flytter farten litt etter litt mot ønsket fart for jevn bevegelse

	# Hopp med coyote time
	if Input.is_action_just_pressed("elf_jump") and coyote_timer > 0:
		if is_boosted:
			velocity.y = JUMP_VELOCITY * boost_multiplier # Sterkere boost-hopp
			is_boosted = false
			play_boost_jump_sound()
		else:
			velocity.y = JUMP_VELOCITY # Vanlig hopp
			play_jump_sound()
		coyote_timer = 0 # Nullstill coyote time

	# Dash
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		start_dash() # Start dash
		play_dash_sound() # Spill dash-lyd

func start_dash():
	is_dashing = true # Nå dusher vi
	dash_timer = dash_duration # Sett dash-varighet
	dash_dir = sign(Input.get_axis("elf_left", "elf_right")) # Hent dash-retning
	if dash_dir == 0:
		dash_dir = 1  # Default høyre hvis ingen input

# Footsteps
func handle_footsteps(delta):
	if is_on_floor() and abs(velocity.x) > 0.1: # Kun når man går på bakken
		var step_interval = footstep_interval / (abs(velocity.x) / speed)  # Raskere steg ved høyere fart
		footstep_timer -= delta

		if footstep_timer <= 0:
			$FootstepSFX.stream = footstep_sfx
			$FootstepSFX.pitch_scale = lerp(1.0, 1.5, abs(velocity.x) / speed) # Pitch øker ved høy fart
			$FootstepSFX.play()
			footstep_timer = step_interval
	else:
		if $FootstepSFX.playing:
			$FootstepSFX.stop() # Stop lyd når man står stille
		footstep_timer = 0

func play_jump_sound():
	$JumpSFX.stream = jump_sfx # Sett riktig lyd
	$JumpSFX.play() # Spill av hopp-lyd

func play_boost_jump_sound():
	$JumpSFX.stream = boost_jump_sfx # Sett boost-hopp lyd
	$JumpSFX.play()

func play_dash_sound():
	$DashSFX.stream = dash_sfx_list[randi() % dash_sfx_list.size()]  # Tilfeldig dash-lyd
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
