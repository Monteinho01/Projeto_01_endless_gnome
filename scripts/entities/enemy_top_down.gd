extends CharacterBody2D
class_name EnemyTopDown
 
const SPEED : float = 100.0
const MAX_HEALTH := 3
const MIN_HEALTH := 0
const AMOUNT_OF_DAMAGE := 1
 
var current_health : int
var isAlive : bool
var direction : Vector2 = Vector2.RIGHT
 
@export var patrol_directions : Array[Vector2] = [
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.UP,
]

var patrol_index : int = 0
 
var knockback : Vector2 = Vector2.ZERO
var knockback_timer : float = 0.0
 
@onready var hit_box := $HitBox
@onready var timer := $Timer
@onready var hurt_sound := $HurtSound
 
func _ready() -> void:
	isAlive = true
	current_health = MAX_HEALTH
	timer.timeout.connect(_moveToward)
 

func _physics_process(delta: float) -> void:
	healthAnalysis()
 
	if not isAlive:
		return
 
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
 
		move_and_slide()
 
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
			velocity = Vector2.ZERO
	else:
		velocity = direction * SPEED
		move_and_slide()
 

func _moveToward() -> void:
	patrol_index = (patrol_index + 1) % patrol_directions.size()
	direction = patrol_directions[patrol_index]
 

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.current_health -= AMOUNT_OF_DAMAGE
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_direction, 300.0, 0.30)
		body.hurt_sound_player()
 

func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
 

func healthAnalysis() -> void:
	if current_health <= MIN_HEALTH and isAlive:
		isAlive = false
	if not isAlive:
		queue_free()
 

func hurt_sound_enemy() -> void:
	hurt_sound.play()
