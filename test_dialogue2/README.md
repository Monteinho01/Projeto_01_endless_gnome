# Resumo sobre o que foi feito


![Godot](https://img.shields.io/badge/Godot-4.4-478cbf?style=flat-square&logo=godotengine)
![GDScript](https://img.shields.io/badge/Language-GDScript-478cbf?style=flat-square)

---

## Mecânicas 

### Combate
- **Ataque Rápido**: Pressione `X` para atacar
- **Cooldown de Ataque**: 0.4 segundos entre ataques
- **Dano**: 1 ponto de dano por acerto
- **Knockback**: Recebe impulso ao ser atingido
- **Sistema de Vida**: 3 pontos de vida por personagem

### Movimento
- **Caminhada**: Movimente-se pela fase com agilidade
- **Pulo**: Salte sobre obstáculos e abismos
- **Velocidade do Gnomo**: 400 unidades/segundo
- **Altura do Pulo**: -850 velocidade de salto
- **Gravidade Realista**: Caída progressiva com efeitos de queda

### Inimigos
- **Movimentação Autônoma**: Patrulham o mapa independentemente
- **Detecção de Obstáculos**: Evitam paredes e abismos
- **IA Básica**: Mudam direção ao encontrar obstáculos
- **Velocidade**: 100 unidades/segundo
- **Durabilidade**: 3 pontos de vida

### Sistema de Câmera
- **Câmera Dinâmica**: Segue o gnomo em tempo real e treme quando ataca uma entidade
- **Foco no Jogador**: Mantém o jogador sempre centralizado

### Diálogos 
- **Sistema de Conversa**: Interaja com NPCs através de diálogos
- **Suporte JSON**: Diálogos estruturados e facilmente editáveis
- **Múltiplos Personagens**: Diferentes NPCs com suas histórias
- **Progresso**: Avance diálogos pressionando `SPACE` ou `ENTER`

### Áudios 
- **Sons de Ação**:
  -  Salto
  -  Ataque
  -  Dano recebido
  -  Morte de inimigo
- **Sons Ambientais**:
  -  Passos rítmicos durante o movimento
  -  Efeitos sonoros com reverberação

###  Transições de Cena
- **Transições Suaves**: Mudança elegante entre níveis
- **Gerenciamento de Cenas**: Sistema automático de transição
- **Game Over**: Tela de morte quando a vida chega a zero

---

## Fases

O jogo possui **dois mundos** para explorar:

| Fase | Nome | Status | Modo |
|------|------|--------|------------|
| 1 | Test World 1 | Disponível | Plataforma 
| 2 | Test World 2 | Disponível | Top-Down

---

## Controles

| Ação | Tecla |
|------|-------|
| **Mover Esquerda/Direita** | ← / → |
| **Pular** | Z |
| **Atacar** | X |
| **Avançar Diálogo** | SPACE / ENTER |

---

## Estrutura do Projeto

```
gnome-game-project/
├── 📂 scenes/                    # Cenas do Godot
│   ├── entities/                 # Personagens e inimigos
│   ├── phases/                   # Níveis/Fases
│   ├── ui/                       # Interface do usuário
│   └── debug/                    # Ferramentas de debug
├── 📂 scripts/                   # Códigos GDScript
│   ├── entities/                 # Lógica de personagens
│   ├── phases/                   # Lógica de fases
│   ├── ui/                       # Lógica de UI
│   └── debug/                    # Scripts de debug
├── 📂 data/                      # Dados do jogo
│   └── dialogs/                  # Arquivos JSON de diálogos
├── 📂 sprites/                   # Imagens e sprite sheets
├── 📂 sfx/                       # Efeitos sonoros
└── 📄 project.godot             # Configuração do projeto
```

---

## Personagens

### O Gnomo (Jogador)
- **HP**: 3 pontos de vida
- **Velocidade**: 400 un/s
- **Ataque**: 1 dano por hit
- **Habilidades**: Pulo, Ataque, Movimento

### Inimigos
- **Tipo 1**: Inimigo Básico (Mundo Base)
  - Velocidade: 100 un/s
  - HP: 3
  - Comportamento: Patrulha simples

- **Tipo 2**: Inimigo Top-Down
  - Variante em visão de cima
  - Mesma mecânica base

---

## Sistema de Áudio

### Diretório de Sons
```
sfx/
├── girotos-sound/
│   ├── 🎵 ataque.ogg
│   ├── 🎵 inimigoMorrendo.ogg
│   ├── 🎵 pulo.ogg
│   └── 👣 step1.ogg / step2.ogg
└── place-holder/
    └── Sons adicionais e ambientais
```

---

## Sistema de Eventos

### Grupos de Nós
- **`enemies`**: Todos os inimigos ("bad guys :0")
- **`player`**: Personagem jogável ("good guy :)")
- **`Camera`**: Câmera do jogo

### Autoload (Singletons)
- **SceneTransitions**: Gerencia transições entre cenas
- **GameOver**: Controla a tela de game over
- **GameManager**: Gerencia o estado geral do jogo

---

## Desenvolvimento

### Requisitos
- **Godot Engine**: 4.4+
- **GDScript**: Nativo

### Como Executar
1. Abra o projeto no Godot 4.4
2. Clique em **Play** (▶️) para testar
3. Use os controles mencionados para jogar

### Extensões Recomendadas
- Godot 4.4 built-in debugger
- Animation tools do Godot
- Tile Set Editor

---

## Estatísticas de Mecânicas

| Parâmetro | Valor |
|-----------|-------|
| Velocidade Jogador | 400 un/s |
| Velocidade Inimigo | 100 un/s |
| Velocidade Pulo | -850 un/s |
| Velocidade Queda | 950 un/s |
| Gravidade Padrão | 980 un/s² |
| Vida Máxima | 3 HP |
| Dano por Ataque | 1 HP |
| Cooldown Ataque | 0.4 seg |
| Resolução | 1920x1080 |

---

## Padrões de Design

### Herança de Cenas
- Personagens herdam de `CharacterBody2D`
- Inimigos utilizam `RayCast2D` para detecção
- NPCs suportam sistema de diálogos JSON

### Sistema de Saúde
- Todas as entidades vivas têm `current_health`
- Dano reduz vida gradualmente
- Morte acionada quando HP ≤ 0

### Feedback Visual
- **Animações Flash**: Indica dano recebido
- **Knockback**: Impulsiona entidades ao receber dano
- **Sprites Animados**: Personagens mudam de pose

---

## Debug & Ferramentas

### Cenas de Debug Disponíveis
- **Death Zone**: Testa zonas de morte
- **Game Manager**: Interface de gerenciamento
- **Game Over**: Tela de morte
- **Scene Transitions**: Testa transições

---

## Diálogos

Os diálogos são armazenados em **JSON** para fácil edição:

```json
[
  {
    "nome": "NPC1",
    "texto": "Olá, aventureiro!"
  },
  {
    "nome": "NPC1",
    "texto": "Você parece forte..."
  }
]
```

**Adicionar novos diálogos**:
1. Crie um arquivo `.json` em `data/dialogs/`
2. Siga o formato acima
3. Chame `iniciar_dialogo("res://data/dialogs/seu_arquivo.json")` no script
