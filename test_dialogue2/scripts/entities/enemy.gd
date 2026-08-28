extends CharacterBody2D
class_name Enemy

const SPEED : float = 100.0
const JUMP_VELOCITY : float = -400.0
const FALL_VELOCITY : float = 600.0

const MAX_HEALTH = 3
const MIN_HEALTH = 0
var current_health : int

const AMOUNT_OF_DAMAGE : int = 1

var gravity = ProjectSettings.get("physics/2d/default_gravity")

@onready var hit_box : Area2D = $HitBox

@onready var sprite : Sprite2D = $Visual

var direction := 1.0

var knockback : Vector2 = Vector2.ZERO
var knockback_timer : float = 0.0 

var isAlive : bool

@onready var hurt_sound : AudioStreamPlayer2D = $HurtSound
@onready var enemy_dying : AudioStreamPlayer2D = $EnemyDying

@onready var hit_flash_animation_player : AnimationPlayer = $HitFlashAnimationPlayer

@onready var wall_detection_ray : RayCast2D = $WallDetectionRay
@onready var ledge_detection_ray : RayCast2D = $LedgeDetectionRay

func _ready() -> void:
	isAlive = true
	current_health = MAX_HEALTH
	
	if sprite.material:
		sprite.material = sprite.material.duplicate()


func _physics_process(delta: float) -> void:	
	
	_update_direction()
	
	healthAnalysis()
	
	if not isAlive:
		return 

	free_fall(delta)
	
	if knockback_timer > 0.0:
		velocity = knockback 
		knockback_timer -= delta
		
		move_and_slide() 
		
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
			velocity.x = 0 
	
	else:
		if direction:
			velocity.x = direction * SPEED
		
		move_and_slide()


func _moveToward():
	direction *= -1.0


func free_fall(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(FALL_VELOCITY, velocity.y + (gravity * 2) * delta)


func _on_hit_box_body_entered(body: Node2D) -> void:
	if isAlive:
		if body.is_in_group("player"):
			
			body.current_health -= AMOUNT_OF_DAMAGE
			
			var knockback_direction = (
				body.global_position - global_position
			).normalized()
			
			body.apply_knockback(
				knockback_direction,
				300.0,
				0.30
			)
			
			body.hurt_sound_player()


func apply_knockback(direction: Vector2, force : float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration


func healthAnalysis() -> void:
	if current_health <= MIN_HEALTH and isAlive:
		die()


func die() -> void:
	isAlive = false
	
	enemy_dying.play()
	
	await enemy_dying.finished
	
	queue_free()



func hurt_sound_enemy():
	
	hurt_sound.play()
	
	hit_flash_animation_player.play("hit_flash")
	
	await get_tree().create_timer(0.5).timeout
	
	hit_flash_animation_player.stop()

func _update_direction() -> void:
	if not wall_detection_ray.is_colliding() and ledge_detection_ray.is_colliding():
		return 
	
	direction *= -1.0
	
	var wall_direction_ray_pos : Vector2 = Vector2(
		wall_detection_ray.target_position.x * -1,
		wall_detection_ray.target_position.y
	)
	
	wall_detection_ray.target_position = wall_direction_ray_pos
	
	var ledge_ray_pos : Vector2 = Vector2(
		ledge_detection_ray.target_position.x * -1,
		ledge_detection_ray.target_position.y
	)
	
	ledge_detection_ray.position = ledge_ray_pos
