extends Node2D

@onready var tilemap: TileMap = $TileMap
@onready var decoration: Node2D = $Decoration

func _ready():
	print("Cenário carregado")

	setup_world()

func setup_world():
	pass
