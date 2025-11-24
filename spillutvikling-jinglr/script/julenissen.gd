extends CharacterBody2D

var speed : float = 300.0
var gravity : float = 1200.0
const JUMP_VELOCITY = -400.0

var direction : Vector2 = Vector2.ZERO

func _physics_process(delta: float):
	apply_gravity(delta)
	get_input()
	move_and_slide()
	update_animation()


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0:
			velocity.y = 0


func get_input():
	direction = Vector2.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1

	velocity.x = direction.x * speed

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func update_animation():
	var animated_sprite = $AnimatedSprite2D

	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction.x < 0
	else:
		animated_sprite.play("idle")
