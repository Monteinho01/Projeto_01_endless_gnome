extends Camera2D

# Valor de zoom da câmera
@export var zoom_value := 2.0

func _ready():
	make_current() # ativa essa câmera
	zoom = Vector2(zoom_value, zoom_value) # aplica zoom
