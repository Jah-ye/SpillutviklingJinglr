extends CharacterBody2D

@export var speed: float = 60.0
@export var roll_speed: float = 180.0   # rotasjon i grader per sekund
@export var direction: Vector2 = Vector2.LEFT  # du kan sette RIGHT etc.

func _physics_process(delta):
	# Bevegelse
	velocity = direction * speed
	move_and_slide()

	# Rulling
	rotation_degrees += roll_speed * delta

extends Node2D

@export var snowball_scene: PackedScene
@export var spawn_interval := 2.0
var timer := 0.0

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0
		spawn_snowball()

func spawn_snowball():
	var s = snowball_scene.instantiate()
	s.position = Vector2(600, 200)   # posisjonen der snøballene kommer fra
	add_child(s)

	

	
	
