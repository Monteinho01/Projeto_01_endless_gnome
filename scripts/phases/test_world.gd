extends Control
class_name TestWorld

@onready var gnomo_player := $Gnomo

@onready var _death_zone := $DeathZone

@onready var savePoint := $SavePoint

var isRespawning : bool
 
func _ready() -> void:
	SceneTransitions.fade_in()
		
	isRespawning = false
	gnomo_player.position = savePoint.global_position

func _process(delta: float) -> void:	
	respawning()


func respawning() -> void:
	if gnomo_player.isAlive:
		if _death_zone.player_in_void:
			isRespawning = true
			await get_tree().create_timer(0.5).timeout
			
		if isRespawning:
			gnomo_player.position = savePoint.global_position
			isRespawning = false
			_death_zone.player_in_void = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	SceneTransitions.fade_out()
	
	await SceneTransitions.fade_complete
	
	get_tree().call_deferred("change_scene_to_file","res://scenes/phases/testWorld2.tscn")
