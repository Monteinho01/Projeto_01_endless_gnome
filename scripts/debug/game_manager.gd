extends Node

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func restart_the_game() -> void:
	get_tree().reload_current_scene()
