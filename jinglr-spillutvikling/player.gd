extends CharacterBody2D


@export var speed: float = 60.0
@export var chase_speed_mul: float = 1.6
@export var patrol_distance: float = 160.0
@export var idle_time: float = 0.4
@export var detection_timeout: float = 1.0
@export var attack_cooldown: float = 1.0
@export var damage_amount: int = 1

enum State { PATROL, CHASE, RETURN, IDLE }

var state: State = State.PATROL
var start_pos: Vector2
var left_point: Vector2
var right_point: Vector2
var target_pos: Vector2
var velocity_vec: Vector2 = Vector2.ZERO
var idle_timer: float = 0.0
var detection_lost_timer: float = 0.0
var attack_timer: float = 0.0
var player_ref: Node = null
var direction: int = 1   # 1 = right, -1 = left

@onready var sprite: Sprite2D = $Sprite2D
@onready var ground_ray: RayCast2D = $GroundRay
@onready var ray_left: RayCast2D = $RayCastLEFT
@onready var ray_right: RayCast2D = $RayCastRIGHT
@onready var vision: Area2D = $Vision
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	start_pos = global_position
	left_point = start_pos + Vector2(-patrol_distance, 0)
	right_point = start_pos + Vector2(patrol_distance, 0)
	target_pos = right_point
	vision.body_entered.connect(_on_vision_entered)
	vision.body_exited.connect(_on_vision_exited)
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	attack_timer = max(0.0, attack_timer - delta)

	match state:
		State.PATROL:
			_patrol_state(delta)
		State.CHASE:
			_chase_state(delta)
		State.RETURN:
			_return_state(delta)
		State.IDLE:
			_idle_state(delta)

	# apply movement through CharacterBody2D
	velocity = velocity_vec
	move_and_slide()

	# flip sprite based on x-velocity (for pixel art use sprite.flip_h)
	if velocity_vec.x != 0:
		sprite.flip_h = velocity_vec.x < 0

# ----- STATES -----
func _patrol_state(delta: float) -> void:
	if idle_timer > 0.0:
		state = State.IDLE
		return

	# hvis det ikke er ground foran, snu
	if not ground_ray.is_colliding():
		_start_idle_and_turn()
		return

	# beveg mot target_pos
	var dir_vec = (target_pos - global_position)
	if dir_vec.length() < 6.0:
		# bytt målpunkt
		target_pos = left_point if target_pos == right_point else right_point
		_start_idle_and_turn()
		return

	direction = 1 if (target_pos.x > global_position.x) else -1
	velocity_vec = Vector2(direction * speed, velocity_vec.y)

func _chase_state(delta: float) -> void:
	if player_ref == null:
		detection_lost_timer += delta
		if detection_lost_timer >= detection_timeout:
			detection_lost_timer = 0.0
			state = State.RETURN
		velocity_vec = Vector2.ZERO
		return

	var dir = (player_ref.global_position - global_position).normalized()
	direction = 1 if dir.x > 0 else -1
	velocity_vec = Vector2(dir.x * speed * chase_speed_mul, velocity_vec.y)

func _return_state(delta: float) -> void:
	# gå til nærmeste patrol-point og fortsett patrulje
	var nearest = left_point if global_position.distance_to(left_point) < global_position.distance_to(right_point) else right_point
	var to_nearest = nearest - global_position
	if to_nearest.length() < 8.0:
		target_pos = right_point if nearest == left_point else left_point
		state = State.PATROL
		_start_idle_and_turn()
		return
	direction = 1 if to_nearest.x > 0 else -1
	velocity_vec = Vector2(direction * speed, velocity_vec.y)

func _idle_state(delta: float) -> void:
	idle_timer -= delta
	velocity_vec = Vector2.ZERO
	if idle_timer <= 0.0:
		state = State.PATROL

# ----- HELPER -----
func _start_idle_and_turn() -> void:
	idle_timer = idle_time
	# vend target (visual handled i physics step)
	state = State.IDLE
	direction *= -1

# ----- SIGNAL HANDLERS -----
func _on_vision_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_ref = body
		state = State.CHASE
		detection_lost_timer = 0.0

func _on_vision_exited(body: Node) -> void:
	if body == player_ref:
		player_ref = null
		detection_lost_timer = 0.0

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# Angrip ved kontakt — men use cooldown
		if attack_timer <= 0.0:
			attack_timer = attack_cooldown
			if body.has_method("take_damage"):
				body.take_damage(damage_amount)
			# evt. dytt spilleren (hvis spiller er RigidBody2D eller har apply_impulse)
			# body.apply_impulse(...)

# ----- UTENFOR -----
func force_return_to_patrol() -> void:
	player_ref = null
	detection_lost_timer = 0.0
	state = State.RETURN
