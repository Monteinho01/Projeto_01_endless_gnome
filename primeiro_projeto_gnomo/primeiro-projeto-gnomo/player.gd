class_name Player
extends CharacterBody2D

# Variáveis configuráveis no editor (velocidade, vida, dano)
@export var speed := 150
@export var max_health := 5
@export var damage := 1

# Controle de ataque e dano
@export var attack_cooldown := 0.3
@export var invulnerability_time := 0.5
@export var knockback_force := 700

# Estados internos
var health := 0
var attacking := false
var can_attack := true
var can_take_damage := true

# Velocidade aplicada quando sofre knockback (empurrão)
var knockback_velocity := Vector2.ZERO

# Referências a nós da cena
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $ItemPosition/WeaponHandler/HitBox

# Instância estática para outros objetos acessarem o player facilmente
static var instance = null

func _ready():
	instance = self # guarda referência global
	health = max_health # inicia com vida máxima

func _physics_process(_delta):
	var direction = Vector2.ZERO

	# Captura input do jogador (movimento)
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	# Normaliza para evitar movimento mais rápido na diagonal
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Aplica velocidade
	velocity = direction * speed

	# Soma o efeito de knockback ao movimento
	velocity += knockback_velocity

	# Faz o knockback desaparecer suavemente
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.08)

	# Move o personagem com colisão
	move_and_slide()

	# Atualiza animação conforme direção
	update_animation(direction)

func update_animation(direction):
	# Se não está se movendo
	if direction == Vector2.ZERO:
		sprite.play("default")
		return

	# Decide animação baseada no eixo dominante
	if abs(direction.x) > abs(direction.y):
		sprite.play("walking_right" if direction.x > 0 else "walking_left")
	else:
		sprite.play("walking_up" if direction.y < 0 else "walking_down")

func _process(_delta):
	# Detecta clique do mouse para atacar
	if Input.is_action_just_pressed("mouse_click") and can_attack:
		attack()

func attack():
	can_attack = false
	attacking = true

	# Pega todas as áreas que estão colidindo com a hitbox
	var areas = hitbox.get_overlapping_areas()

	for area in areas:
		var target = area.get_parent()

		# Verifica se o alvo pode receber dano
		if target != self and target.has_method("take_damage"):
			target.take_damage(damage, global_position) # passa posição para knockback

	# Espera cooldown antes de permitir novo ataque
	await get_tree().create_timer(attack_cooldown).timeout

	attacking = false
	can_attack = true

func take_damage(amount: int, attacker_pos: Vector2):
	# Evita dano repetido em curto tempo
	if not can_take_damage:
		return

	can_take_damage = false

	health -= amount
	flash()

	# Calcula direção do empurrão (oposta ao atacante)
	var dir = (global_position - attacker_pos).normalized()
	knockback_velocity = dir * knockback_force

	if health <= 0:
		queue_free() # remove o player da cena

	# Tempo de invulnerabilidade
	await get_tree().create_timer(invulnerability_time).timeout
	can_take_damage = true

func flash():
	# Efeito visual ao tomar dano
	sprite.modulate = Color(5,5,5)

	await get_tree().create_timer(0.1).timeout

	sprite.modulate = Color(1,1,1)
