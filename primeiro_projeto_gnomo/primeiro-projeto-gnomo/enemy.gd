extends CharacterBody2D

# Configurações do inimigo
@export var speed := 80
@export var max_health := 3
@export var damage := 1

@export var attack_cooldown := 1.0
@export var attack_pause := 1.0

@export var invulnerability_time := 0.4
@export var knockback_force := 500

var health := 0
var player = null

# Controle de movimento e combate
var knockback_velocity := Vector2.ZERO
var can_attack := true
var can_take_damage := true
var is_attacking := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	health = max_health

func _physics_process(_delta):
	# Pega referência do player
	if player == null:
		player = Player.instance
	if player == null:
		return

	# Calcula direção até o player
	var direction = player.global_position - global_position
	var distance = direction.length()

	if is_attacking:
		velocity = knockback_velocity
	else:
		# Se estiver longe, persegue o player
		if distance > 10:
			direction = direction.normalized()
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO

	# Aplica knockback
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.08)

	move_and_slide()

	# Se estiver perto, ataca
	if distance < 45 and can_attack and not is_attacking:
		attack()

func attack():
	if player == null:
		return

	can_attack = false
	is_attacking = true

	# Causa dano diretamente no player
	player.take_damage(damage, global_position)

	# Pequena pausa durante ataque
	await get_tree().create_timer(attack_pause).timeout
	is_attacking = false

	# Cooldown até próximo ataque
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount: int, attacker_pos: Vector2):
	if not can_take_damage:
		return

	can_take_damage = false

	health -= amount
	flash()

	# Aplica knockback
	var dir = (global_position - attacker_pos).normalized()
	knockback_velocity = dir * knockback_force

	if health <= 0:
		queue_free()

	await get_tree().create_timer(invulnerability_time).timeout
	can_take_damage = true

func flash():
	sprite.modulate = Color(5,5,5)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1,1,1)
