# exit_terminal.gd — Locked exit that opens when puzzle is complete
# Blocks the player with a StaticBody2D until both conditions are met:
# 1. Generator is powered
# 2. Power is rerouted
extends Node2D

@onready var blocker: StaticBody2D = $Blocker
@onready var sprite: Sprite2D = $Sprite2D
@onready var status_label: Label = $StatusLabel

func _ready():
	# Connect to puzzle state signals
	PuzzleState.generator_powered.connect(_update_state)
	PuzzleState.power_rerouted.connect(_update_state)
	PuzzleState.puzzle_complete.connect(_open_door)
	_update_state()

func _update_state():
	if PuzzleState.is_generator_powered and PuzzleState.is_power_rerouted:
		_open_door()
	elif PuzzleState.is_generator_powered:
		if status_label:
			status_label.text = "Power Active — Reroute Needed"
	elif PuzzleState.is_power_rerouted:
		if status_label:
			status_label.text = "Route Set — No Power"
	else:
		if status_label:
			status_label.text = "EXIT LOCKED"

func _open_door():
	# Remove the physical blocker
	if blocker:
		blocker.queue_free()
	
	# Visual feedback
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(0.3, 1.0, 0.3), 0.8)
	
	if status_label:
		status_label.text = "EXIT OPEN"
	
	print("[ExitTerminal] Door opened!")
