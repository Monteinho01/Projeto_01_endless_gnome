extends CharacterBody2D

@export var arquivo_dialogo: String = "res://data/dialogs/fala_npc1.json"

@onready var area_interacao: Area2D = $Area2D

var player_na_area: bool = false

func _ready() -> void:
	# Detecta tanto corpos físicos quanto outras Area2D (como a HitBox do player)
	area_interacao.body_entered.connect(_on_entrou_na_area)
	area_interacao.body_exited.connect(_on_saiu_da_area)
	area_interacao.area_entered.connect(_on_entrou_na_area)
	area_interacao.area_exited.connect(_on_saiu_da_area)

func _unhandled_input(_event: InputEvent) -> void:
	if player_na_area and Input.is_action_just_pressed("ui_accept"):
		print("ENTER pressionado! Tentando abrir diálogo...")
		
		var box = get_tree().get_first_node_in_group("dialogue_box")
		if not box:
			box = get_parent().get_node_or_null("dialogue_box")
			
		if box and box.has_method("iniciar_dialogo"):
			box.iniciar_dialogo(arquivo_dialogo)
		else:
			print("Erro: dialogue_box não encontrada ou sem método iniciar_dialogo!")

func _on_entrou_na_area(objeto: Node) -> void:
	if objeto.is_in_group("player") or objeto.get_parent().is_in_group("player"):
		print("Player ENTROU na área do NPC!")
		player_na_area = true

func _on_saiu_da_area(objeto: Node) -> void:
	if objeto.is_in_group("player") or objeto.get_parent().is_in_group("player"):
		print("Player SAIU da área do NPC!")
		player_na_area = false
