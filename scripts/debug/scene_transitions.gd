extends Node

signal fade_complete

@onready var fade_to_black : ColorRect = $CanvasLayer/FadeToBlack
@onready var animation_player : AnimationPlayer = $AnimationPlayer

@onready var transition_sound : AudioStreamPlayer2D = $TransitionSound

func _ready() -> void:
	fade_to_black.hide()
	
func fade_in() -> void:
	fade_to_black.show()
	animation_player.play("scene_transition")
	
	transition_sound.play()
	
	await animation_player.animation_finished
	fade_to_black.hide()
	
func fade_out() -> void:
	fade_to_black.show()
	animation_player.play_backwards("scene_transition")
	
	await animation_player.animation_finished
	fade_to_black.hide()

	fade_complete.emit()
