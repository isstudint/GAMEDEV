# lever.gd — Interactive lever that can control Gears, Ladders, Moving Platforms, and Power Reroute
extends Node2D

## Drag targets here in the Inspector to connect them
@export var target_gear: NodePath
@export var target_ladder: NodePath
@export var target_platform: NodePath

## Enable this to make this lever reroute power (for the puzzle system)
@export var reroutes_power: bool = false

## Visual rotation when lever is ON vs OFF (degrees for the Leverstick)
@export var lever_on_angle: float = -30.0
@export var lever_off_angle: float = 30.0
@export var lever_tween_time: float = 0.5

## How thick the outline is when highlighted
@export var outline_width: float = 10.0

var is_on: bool = false
var _gear_node: Node2D = null
var _ladder_node: Node2D = null
var _platform_node: Node2D = null
var _player_in_range: bool = false

@onready var lever_stick: Sprite2D = $Leverstick
@onready var lever_base: Sprite2D = $Leverbase
@onready var interact_area: Area2D = $InteractArea
@onready var interact_label: Label = $InteractLabel

func _ready() -> void:
	# Resolve references
	if target_gear and not target_gear.is_empty():
		_gear_node = get_node_or_null(target_gear)
	if target_ladder and not target_ladder.is_empty():
		_ladder_node = get_node_or_null(target_ladder)
	if target_platform and not target_platform.is_empty():
		_platform_node = get_node_or_null(target_platform)
	
	if lever_stick:
		lever_stick.rotation_degrees = lever_off_angle

	# Hide outline and label by default
	_set_outline(false)
	if interact_label:
		interact_label.visible = false

	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_set_outline(true)
		if interact_label:
			interact_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_set_outline(false)
		if interact_label:
			interact_label.visible = false


func _set_outline(on: bool) -> void:
	var w = outline_width if on else 0.0
	if lever_base and lever_base.material:
		lever_base.material.set_shader_parameter("width", w)
	if lever_stick and lever_stick.material:
		lever_stick.material.set_shader_parameter("width", w)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _player_in_range:
		_toggle_lever()
		get_viewport().set_input_as_handled()


func _toggle_lever() -> void:
	is_on = !is_on
	
	# Animate the lever stick
	if lever_stick:
		var target_angle = lever_on_angle if is_on else lever_off_angle
		var tween = create_tween()
		tween.tween_property(lever_stick, "rotation_degrees", target_angle, lever_tween_time)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Toggle the gear
	if _gear_node and _gear_node.has_method("toggle_spin"):
		_gear_node.toggle_spin()
	
	# Drop the ladder
	if _ladder_node and _ladder_node.has_method("drop"):
		_ladder_node.drop()
	
	# Activate/deactivate the moving platform
	if _platform_node and _platform_node.has_method("activate"):
		_platform_node.activate()
	
	# Reroute power for the puzzle system
	if reroutes_power and is_on:
		PuzzleState.reroute_power()
