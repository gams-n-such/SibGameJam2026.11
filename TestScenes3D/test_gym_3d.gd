extends Node3D


func _ready() -> void:
	Game.change_game_state(GameState.GAMEPLAY)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
