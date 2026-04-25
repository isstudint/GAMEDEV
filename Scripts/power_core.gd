# power_core.gd — Collectible Power Core item
# Place in the Past timeline. Player interacts to pick it up.
extends Node2D

@export var outline_width: float = 5.0

var _player_in_range: bool = false
var _collected: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $InteractArea
@onready var interact_label: Label = $InteractLabel

func _ready():
	if interact_label:
		interact_label.visible = false
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
	
	# If core was already collected, hide it
	if PuzzleState.has_power_core or PuzzleState.is_generator_powered:
		_collected = true
		visible = false

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and not _collected:
		_player_in_range = true
		if interact_label:
			interact_label.visible = true
		if sprite and sprite.material:
			sprite.material.set_shader_parameter("width", outline_width)

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		_player_in_range = false
		if interact_label:
			interact_label.visible = false
		if sprite and sprite.material:
			sprite.material.set_shader_parameter("width", 0.0)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("interact") and _player_in_range and not _collected:
		_collect()
		get_viewport().set_input_as_handled()

func _collect():
	_collected = true
	PuzzleState.collect_power_core()
	
	# Fade out and disappear
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func(): visible = false)
	
	if interact_label:
		interact_label.visible = false
