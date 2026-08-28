extends Control

@onready var gameover_screen : Sprite2D = $CanvasLayer/GameOver_sprite
@onready var gameover_warning : Label = $CanvasLayer/Label
@onready var fade_to_black : ColorRect = $CanvasLayer/FadeToBlack
@onready var animation_player : AnimationPlayer = $AnimationPlayer

@onready var gameover_sound : AudioStreamPlayer = $GameOverSong

var is_gameover : bool

func _ready() -> void:
	is_gameover = false
	
	fade_to_black.hide()
	gameover_screen.hide()
	gameover_warning.hide()
	
func show_screen() -> void:
	fade_to_black.show()
	animation_player.play("fade_to_black")
	gameover_sound.play()
	await animation_player.animation_finished
	gameover_screen.show()
	gameover_warning.show()
	is_gameover = true

func _input(event):
	if event.is_action_pressed("ui_accept") and is_gameover:
		GameManager.restart_the_game()
		gameover_screen.hide()
		gameover_warning.hide()
		gameover_sound.stop()
		fade_to_black.hide()
		is_gameover = false

	
