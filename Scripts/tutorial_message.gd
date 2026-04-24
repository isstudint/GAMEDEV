@tool
extends Area2D

@export_multiline var message: String = "Tut" :
	set(value):
		message = value
		if is_node_ready():
			$VBoxContainer/PanelContainer/Label.text = value

@onready var container = $VBoxContainer
var _tween: Tween

func _ready() -> void:
	# Keep text synced in editor
	container.get_node("PanelContainer/Label").text = message
	
	if Engine.is_editor_hint():
		container.modulate.a = 1.0
		return
		
	# Hide initially in game
	container.modulate.a = 0.0
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint(): return
	if body.is_in_group("player"):
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(container, "modulate:a", 1.0, 0.3)

func _on_body_exited(body: Node2D) -> void:
	if Engine.is_editor_hint(): return
	if body.is_in_group("player"):
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(container, "modulate:a", 0.0, 0.3)
