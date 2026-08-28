extends CharacterBody2D

# Caminho exato da sua pasta de arquivos que aparece na imagem!
@export_file("*.json") var dialogo_json: String = "res://data/dialogs/fala_npc1.json"

@onready var area_2d: Area2D = $Area2D

var player_perto: bool = false
var player_ref: CharacterBody2D = null

func _ready() -> void:
	if area_2d:
		area_2d.body_entered.connect(_on_body_entered)
		area_2d.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if player_perto and event.is_action_pressed("ui_accept"):
		var caixa = get_tree().get_first_node_in_group("caixa_dialogo")
		
		if caixa:
			if player_ref and player_ref.has_method("travar_movimento"):
				player_ref.travar_movimento()
			
			caixa.iniciar(dialogo_json, player_ref)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("gnome") or body is CharacterBody2D:
		player_perto = true
		player_ref = body as CharacterBody2D

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("gnome") or body is CharacterBody2D:
		player_perto = false
		player_ref = null
