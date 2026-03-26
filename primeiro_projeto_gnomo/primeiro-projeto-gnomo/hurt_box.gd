extends Area2D

func _ready():
	# Define camadas de colisão
	collision_layer = 1
	collision_mask = 2
	monitoring = true

	# Conecta sinal quando algo entra na área
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(hitbox):
	# Verifica se quem entrou é uma HitBox
	if hitbox is HitBox:
		# Se o dono tiver método de dano
		if owner != null and owner.has_method("take_damage"):
			owner.take_damage(hitbox.damage)
