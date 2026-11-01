extends Control

@onready var coward_label: Label = %CowardLabel

func _ready() -> void:
	Game.player.coward.connect(coward)


func _process(delta: float) -> void:
	pass

var tween : Tween

func coward() -> void:
	coward_label.visible = true
	coward_label.modulate = Color.WHITE
	if tween:
		tween.kill()
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_interval(0.5)
	tween.tween_property(coward_label, "modulate", Color.TRANSPARENT, 2.0)
