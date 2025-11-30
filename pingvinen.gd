# Penguin.gd
extends CharacterBody2D

@export var speed = 80.0
@export var initial_direction = -1

var direction = 1
var gravity = 980.0
var sprite_node: Sprite2D 

var ray_right: RayCast2D
var ray_left: RayCast2D

func _ready():
	ray_right = $RayCastright
	ray_left = $RayCastleft
	sprite_node = $Sprite2D
	
	direction = initial_direction
	update_visuals_and_rays()

func _physics_process(delta):
   
	
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = speed * direction
	
	# 
	move_and_slide()
	
	check_for_turn()



func check_for_turn():
	#
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		if abs(collision.get_normal().dot(Vector2.UP)) < 0.1:
			change_direction()
			return
	
	
	if is_on_floor():
		var active_ray = ray_right if direction == 1 else ray_left
		
		if active_ray.is_colliding() == false:
			change_direction()

func change_direction():
	direction *= -1
	update_visuals_and_rays()

func update_visuals_and_rays():
	if sprite_node:
		sprite_node.flip_h = (direction == 1)

	if direction == 1:
		ray_right.enabled = true
		ray_left.enabled = false
	else:
		ray_right.enabled = false
		ray_left.enabled = true



func _on_HitBox_body_entered(body):
	if body.has_method("damage"):
		body.damage()
