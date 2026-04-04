# lever.gd — Interactive lever that toggles a connected Gear's spinning
extends Node2D

## Drag the Gear node here in the Inspector to connect them
@export var target_gear: NodePath

## How close the player must be to interact (in pixels)
@export var interact_distance: float = 150.0

## Visual rotation when lever is ON vs OFF (degrees for the Leverstick)
@export var lever_on_angle: float = -30.0
@export var lever_off_angle: float = 30.0
@export var lever_tween_time: float = 0.5

var is_on: bool = false
var _gear_node: Node2D = null

@onready var lever_stick: Sprite2D = $Leverstick
@onready var lever_base: Sprite2D = $Leverbase
@onready var interact_area: Area2D = $InteractArea

## How thick the outline is when visible
@export var outline_width: float = 10.0

func _ready() -> void:
	# Resolve the gear reference
	if target_gear and not target_gear.is_empty():
		_gear_node = get_node_or_null(target_gear)
	
	if lever_stick:
		lever_stick.rotation_degrees = lever_off_angle

	# Hide outline by default
	_set_outline(false)

	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)

var _player_in_range: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_set_outline(true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_set_outline(false)

func _set_outline(on: bool) -> void:
	var w = outline_width if on else 0.0
	lever_base.material.set_shader_parameter("width", w)
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
		print("Lever toggled → Gear spinning: ", _gear_node.is_spinning)
	else:
		push_warning("Lever: No gear connected or gear missing toggle_spin() method!")
