extends CanvasLayer

enum { IDLE, READING, WAITING }

@export var CHAR_RATE: float = 0.03

@onready var textbox_container: MarginContainer = $MarginContainer
@onready var label: Label = $MarginContainer/MarginContainer/HBoxContainer/Label
@onready var icon_npc: Node2D = $Icon_npc
@onready var icon_gnome: Node2D = $Icon_gnome

var falas: Array = []
var index: int = 0
var estado: int = IDLE
var em_dialogo: bool = false
var conversas_concluidas: Dictionary = {}
var fala_final_atual: String = "..."
var caminho_json_atual: String = ""
var tween: Tween
var player_salvo: CharacterBody2D = null

func _ready() -> void:
	add_to_group("caixa_dialogo")
	if label:
		label.add_theme_color_override("font_color", Color.WHITE)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	toggle_box(false)

func iniciar(caminho_json: String, player: CharacterBody2D = null, _no_inicial: String = "") -> void:
	if em_dialogo: return
	player_salvo = player
	caminho_json_atual = caminho_json
	index = 0
	
	var mundo = get_tree().current_scene.name
	var chave = caminho_json + "_" + mundo
	
	if conversas_concluidas.get(chave, false):
		falas = [{"nome": "npc", "texto": conversas_concluidas.get(chave + "_texto", "...")}]
	elif FileAccess.file_exists(caminho_json):
		var data = JSON.parse_string(FileAccess.open(caminho_json, FileAccess.READ).get_as_text())
		if data is Array:
			var bloco = data.filter(func(b): return b is Dictionary and b.get("id") == mundo)
			var item = bloco[0] if not bloco.is_empty() else (data[0] if not data.is_empty() else {})
			falas = item.get("falas", []).duplicate()
			fala_final_atual = item.get("dialogo_final", "...")
			
	if not falas.is_empty():
		em_dialogo = true
		mostra_fala()

func _input(event: InputEvent) -> void:
	if not textbox_container.visible or not em_dialogo or not event.is_action_pressed("ui_accept"): return
	get_viewport().set_input_as_handled()
	
	if estado == READING:
		if tween: tween.kill()
		label.visible_ratio = 1.0
		estado = WAITING
	elif estado == WAITING:
		index += 1
		if index < falas.size(): mostra_fala()
		else: fechar()

func mostra_fala() -> void:
	var item = falas[index]
	var texto = item.get("texto", "") if item is Dictionary else str(item)
	var quem = item.get("nome", "npc") if item is Dictionary else "npc"

	icon_npc.visible = quem.to_lower() not in ["gnomo", "player"]
	icon_gnome.visible = not icon_npc.visible
	
	label.text = texto
	label.visible_ratio = 0.0
	toggle_box(true)
	estado = READING
	
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, max(0.1, texto.length() * CHAR_RATE))
	tween.finished.connect(func(): if estado == READING: estado = WAITING, CONNECT_ONE_SHOT)

func fechar() -> void:
	toggle_box(false)
	em_dialogo = false
	var chave = caminho_json_atual + "_" + get_tree().current_scene.name
	conversas_concluidas[chave] = true
	conversas_concluidas[chave + "_texto"] = fala_final_atual
	if player_salvo and player_salvo.has_method("destravar_movimento"):
		player_salvo.destravar_movimento()
	player_salvo = null

func toggle_box(mostrar: bool) -> void:
	textbox_container.visible = mostrar
	if not mostrar:
		label.text = ""
		icon_npc.hide()
		icon_gnome.hide()
		estado = IDLE
