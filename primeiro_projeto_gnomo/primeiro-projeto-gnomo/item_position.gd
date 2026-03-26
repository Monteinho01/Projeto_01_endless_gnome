extends Node2D

# Distância do item em relação ao player
@export var distance := 40

func _process(_delta):
	var mouse_pos = get_global_mouse_position()

	# Direção do player até o mouse
	var direction = mouse_pos - get_parent().global_position

	# Evita bug quando o mouse está muito próximo
	if direction.length() < 5:
		return

	direction = direction.normalized()

	# Posiciona o item ao redor do player
	global_position = get_parent().global_position + direction * distance

	# Rotaciona o item para apontar para o mouse
	rotation = direction.angle()
