extends CharacterBody2D
class_name PlayerController

const SPEED = 400.0

const JUMP_VELOCITY = -850.0

var gravity : float = ProjectSettings.get("physics/2d/default_gravity")

@onready var camera : Camera2D = get_tree().get_first_node_in_group("Camera")

const FALL_VELOCITY = 950

const MAX_HEALTH = 3
const MIN_HEALTH = 0
var current_health : int

const AMOUNT_OF_DAMAGE : int = 1

var knockback : Vector2 = Vector2.ZERO
var knockback_timer : float = 0.0 

var cooldown_attack : float = 0.4
var attack_timer : float = 0.0

var isAlive : bool
var isAttacking : bool
var isWalking : bool
var isPlayingSteps : bool
var isJumping : bool

@onready var animation_player := $AnimationPlayer
@onready var hit_flash_animation_player := $HitFlashAnimationPlayer

@onready var gnome_sprite := $Visual 

@onready var jump_sound := $Jump
@onready var hurt_sfx := $HurtSound
@onready var attack_sound := $AttackSound
@onready var step1 := $Step1
@onready var step2 := $Step2

@onready var hit_box := $HitBox


func _ready() -> void:
	hit_box.monitoring = true
	
	isWalking = false
	isPlayingSteps = false
	isJumping = false
	
	isAlive = true
	isAttacking = false
	
	current_health = MAX_HEALTH
	hit_box.visible = false


func _physics_process(delta: float) -> void:
	
	camera.global_position = global_position # fiz isso pra camera seguir a posicao do player
	
	healthAnalysis()
	
	if attack_timer > 0:
		attack_timer -= delta
	
	if !isAlive:
		return
	
	freefall(delta)
	
	jump()
	
	attack()

	update_animation()
	
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
	else:
		_movement()
		
	move_and_slide()


func get_new_animation() -> String:
	var new_animation : String
	
	if abs(velocity.x) > 0.1:
		new_animation = "walking"  
	else:
		new_animation = "idle"
	
	return new_animation


func update_animation() -> void:
	if get_new_animation() != animation_player.current_animation:
		animation_player.play(get_new_animation())


func jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		isJumping = true
		velocity.y = JUMP_VELOCITY
		jump_sound.play()


func _movement() -> void:
	if !isAlive:
		return
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
		isWalking = true
		
	else:
		isWalking = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction > 0:
		hit_box.position.x = abs(hit_box.position.x)
		gnome_sprite.flip_h = false
		isWalking = true
		
	elif direction < 0:
		hit_box.position.x = -abs(hit_box.position.x)
		gnome_sprite.flip_h = true
		isWalking = true
	
	if isWalking and is_on_floor() and not isPlayingSteps:
		play_steps()


func freefall(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(FALL_VELOCITY, velocity.y + (gravity * 2) * delta)


func healthAnalysis() -> void:
	if current_health <= MIN_HEALTH and isAlive:
		isAlive = false
		GameOver.show_screen()
		print("You Died")
		

func attack() -> void:
	if Input.is_action_just_pressed("attack") and attack_timer <= 0:
		
		attack_timer = cooldown_attack
		
		hit_box.visible = true
		isAttacking = true
		attack_sound.play()
		
		var bodies_in_range = hit_box.get_overlapping_bodies()
		
		for body in bodies_in_range:
			if body.is_in_group("enemies"):
				camera.trigger_shake()
				body.current_health -= AMOUNT_OF_DAMAGE
				
				var knockback_direction = (body.global_position - global_position).normalized()
				
				body.hurt_sound_enemy()
				
				if body.has_method("apply_knockback"):
					body.apply_knockback(knockback_direction, 300.0, 0.30)
		
		await get_tree().create_timer(0.2).timeout
		
		hit_box.visible = false
		isAttacking = false


func apply_knockback(direction: Vector2, force : float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration


func hurt_sound_player() -> void:
	if isAlive:
		hurt_sfx.play()
	
	hit_flash_animation_player.play("hit_flash")
	await get_tree().create_timer(0.5).timeout
	hit_flash_animation_player.stop()


func play_steps() -> void:
	isPlayingSteps = true
	
	step2.play()
	await get_tree().create_timer(0.3).timeout
	
	if not isWalking:
		isPlayingSteps = false
		return
	
	step1.play()
	await get_tree().create_timer(0.3).timeout
	
	isPlayingSteps = false
