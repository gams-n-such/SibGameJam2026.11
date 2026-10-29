class_name TitleScene
extends Node

@export var main_menu_scene : PackedScene

func _ready() -> void:
	Game.change_game_state(GameState.MENU)
