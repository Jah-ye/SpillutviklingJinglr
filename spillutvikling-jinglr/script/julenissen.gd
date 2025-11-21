extends CharacterBody2D

var speed : float = 300.0
var direction : Vector2 = Vector2.ZERO

func _physics_process(delta: float):
	# Get player input
	get_input()
	
	move_and_slide()
	
	update_animation()

func get_input():
	direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
		
	velocity = direction * speed

func update_animation():
	var animated_sprite = $AnimatedSprite2D 
	
	if direction.x != 0 or direction.y != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction.x < 0
	else:
		animated_sprite.animation = "idle"
