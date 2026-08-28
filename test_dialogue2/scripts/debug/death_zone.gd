extends Area2D

const AMOUNT_OF_DAMAGE : int = 1

var player_in_void : bool

func _ready() -> void:
	player_in_void = false
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.current_health -= 100 # hitkill pro mob xd
		return
		
	elif body.is_in_group("player"):
		body.current_health -= AMOUNT_OF_DAMAGE
		player_in_void = true
	else:
		player_in_void = false
	
	
