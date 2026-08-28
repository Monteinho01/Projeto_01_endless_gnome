extends CharacterBody2D
class_name GnomoTopdown
 
const SPEED := 400.0
const MAX_HEALTH := 3
const MIN_HEALTH := 0
const AMOUNT_OF_DAMAGE := 1
 
var current_health : int
var isAlive : bool
var isAttacking : bool
 
var facing : Vector2 = Vector2.DOWN
 
var knockback : Vector2 = Vector2.ZERO
var knockback_timer : float = 0.0
 
var hit_box_offset_distance : float = 0.0
 
@onready var animation_player := $AnimationPlayer
@onready var gnome_sprite := $Visual
@onready var hurt_sfx := $HurtSound
@onready var hit_box := $HitBox
 
func _ready() -> void:
	hit_box.monitoring = true
 
	isAlive = true
	isAttacking = false
 
	current_health = MAX_HEALTH
	hit_box.visible = false
 
	hit_box_offset_distance = hit_box.position.length()
	if hit_box_offset_distance == 0.0:
		hit_box_offset_distance = 16.0
	_update_hit_box_position()
 

func _physics_process(delta: float) -> void:
	healthAnalysis()
 
	if not isAlive:
		return
 
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
 

func _direction_to_label(dir: Vector2) -> String:
	if absf(dir.x) > absf(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "front" if dir.y > 0 else "back"
 

func get_new_animation() -> String:
	var label := _direction_to_label(facing)
	return "walk_%s" % label
 

func update_animation() -> void:
	if velocity.length() > 0.1:

		if get_new_animation() != animation_player.current_animation:
			animation_player.play(get_new_animation())
		animation_player.speed_scale = 1.0
	else:
		animation_player.speed_scale = 0.0
 

func _movement() -> void:
	if not isAlive:
		return
 
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
 
	if input_dir != Vector2.ZERO:
		velocity = input_dir.normalized() * SPEED
		facing = input_dir.normalized()
		_update_hit_box_position()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
		
func _update_hit_box_position() -> void:
	var label := _direction_to_label(facing)
	match label:
		"right":
			hit_box.position = Vector2(hit_box_offset_distance, 0)
		"left":
			hit_box.position = Vector2(-hit_box_offset_distance, 0)
		"front":
			hit_box.position = Vector2(0, hit_box_offset_distance)
		"back":
			hit_box.position = Vector2(0, -hit_box_offset_distance)
 

func healthAnalysis() -> void:
	if current_health <= MIN_HEALTH and isAlive:
		isAlive = false
		GameOver.show_screen()
		print("You Died")
 

func attack() -> void:
	if Input.is_action_just_pressed("attack"):
		hit_box.visible = true
		isAttacking = true
 
		var bodies_in_range = hit_box.get_overlapping_bodies()
		for body in bodies_in_range:
			if body.is_in_group("enemies"):
				body.current_health -= AMOUNT_OF_DAMAGE
				var knockback_direction = (body.global_position - global_position).normalized()
				body.hurt_sound_enemy()
				if body.has_method("apply_knockback"):
					body.apply_knockback(knockback_direction, 300.0, 0.30)
 
		await get_tree().create_timer(0.2).timeout
		hit_box.visible = false
		isAttacking = false
 

func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
 

func hurt_sound_player() -> void:
	hurt_sfx.play()
 
