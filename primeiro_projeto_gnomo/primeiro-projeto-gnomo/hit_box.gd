class_name HitBox
extends Area2D

# Dano causado
@export var damage := 1

func _ready():
	monitoring = true # ativa detecção de colisão
