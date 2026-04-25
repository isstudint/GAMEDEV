# generator.gd — Generator that accepts the Power Core
# Place in the Present timeline. Player inserts core to power it on.
extends Node2D

@export var outline_width: float = 5.0

var _player_in_range: bool = false
var _powered: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $InteractArea
@onready var interact_label: Label = $InteractLabel

func _ready():
	if interact_label:
		interact_label.visible = false
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
	
	# If generator was already powered, show powered state
	if PuzzleState.is_generator_powered:
		_powered = true
		_show_powered()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		_player_in_range = true
		if not _powered:
			if PuzzleState.has_power_core:
				if interact_label:
					interact_label.text = "F to Insert Core"
					interact_label.visible = true
			else:
				if interact_label:
					interact_label.text = "Needs Power Core"
					interact_label.visible = true
		else:
			if interact_label:
				interact_label.text = "Generator Active"
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
	if event.is_action_pressed("interact") and _player_in_range and not _powered:
		if PuzzleState.has_power_core:
			_activate()
			get_viewport().set_input_as_handled()

func _activate():
	_powered = true
	PuzzleState.power_generator()
	_show_powered()
	
	if interact_label:
		interact_label.text = "Generator Active"

func _show_powered():
	# Visual feedback — turn the sprite green/bright
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(0.5, 1.0, 0.5), 0.5)
