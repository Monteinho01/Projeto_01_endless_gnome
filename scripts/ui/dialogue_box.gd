extends CanvasLayer

var label_texto: Label
var dialogos: Array = []
var indice_atual: int = 0
var esta_ativo: bool = false

func _ready() -> void:
	# Encontra qualquer nó Label dentro desta cena sem depender de caminho estático
	label_texto = find_child("Label", true, false) as Label
	if label_texto == null:
		print("ERRO: Nenhum no Label foi encontrado no dialogue_box!")
	hide()

func iniciar_dialogo(caminho_json: String) -> void:
	dialogos = carregar_json(caminho_json)
	if dialogos.size() > 0:
		indice_atual = 0
		esta_ativo = true
		show()
		exibir_fala()

func exibir_fala() -> void:
	if indice_atual < dialogos.size():
		var fala = dialogos[indice_atual]
		if label_texto:
			label_texto.text = "%s: %s" % [fala.get("nome", ""), fala.get("texto", "")]
	else:
		encerrar_dialogo()

func _unhandled_input(_event: InputEvent) -> void:
	if esta_ativo and Input.is_action_just_pressed("ui_accept"):
		indice_atual += 1
		exibir_fala()

func encerrar_dialogo() -> void:
	esta_ativo = false
	hide()

func carregar_json(caminho: String) -> Array:
	if FileAccess.file_exists(caminho):
		var arquivo = FileAccess.open(caminho, FileAccess.READ)
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		var json = JSON.new()
		if json.parse(conteudo) == OK:
			return json.data
	print("Erro ao carregar o arquivo JSON em: ", caminho)
	return []
