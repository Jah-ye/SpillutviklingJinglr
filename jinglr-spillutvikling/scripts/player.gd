extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0  # Negative because Y+ is down in Godot

func _physics_process(_delta: float) -> void:
	var direction = 0

	# Check left/right input
	if Input.is_action_pressed("move_right"):
		direction += 1
	if Input.is_action_pressed("move_left"):
		direction -= 1

	# Set horizontal velocity
	velocity.x = direction * speed

	# Jump if on floor
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Apply movement
	move_and_slide()
