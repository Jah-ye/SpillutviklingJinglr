extends CharacterBody2D

@export var speed: float = 80.0
@export var detection_range: float = 400.0
@export var attack_range: float = 40.0
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.0   # sekunder mellom hvert angrep

var players: Array = []
var target: Node = null
var can_attack: bool = true

func _ready():
	# spillere merkes i grupper: "player1" og "player2"
	var p1 = get_tree().get_first_node_in_group("player1")
	var p2 = get_tree().get_first_node_in_group("player2")

	if p1:
		players.append(p1)
	if p2:
		players.append(p2)

func _physics_process(_delta):
	find_target()

	if not target:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance = global_position.distance_to(target.global_position)

	if distance <= attack_range:
		attack()
		velocity = Vector2.ZERO
	else:
		chase_target()

	move_and_slide()

func find_target():
	var nearest = null
	var nearest_dist = detection_range

	for p in players:
		if p and p.is_inside_tree():
			var dist = global_position.distance_to(p.global_position)
			if dist < nearest_dist:
				nearest = p
				nearest_dist = dist

	target = nearest

func chase_target():
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed

	if dir.x != 0:
		scale.x = sign(dir.x)

func attack():
	if not can_attack:
		return

	can_attack = false

	# skade spilleren om den har take_damage()
	if "take_damage" in target:
		target.take_damage(attack_damage)

	# start cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
	
