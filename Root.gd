extends Node2D

@onready var LevelPast = $LevelPast
@onready var LevelPresent = $LevelPresent

var is_past = false
var can_switch = true
var switch_cooldown = 0
var number_of_switching = 5.0


func _ready():
	_apply_timeline()


func _input(event):
	if event.is_action_pressed("switch_time"):
		if can_switch:
			_switch()
		else:
			print("skill on cooldown")


func _switch():
	can_switch = false
	is_past = !is_past
	_apply_timeline()
	await get_tree().create_timer(switch_cooldown).timeout
	can_switch = true


func _apply_timeline():
	_toggle(LevelPast, is_past)
	_toggle(LevelPresent, !is_past)


func _toggle(node: Node, on: bool):
	if node is CanvasItem:
		node.visible = on
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", !on)
	if node is TileMapLayer:
		node.enabled = on
	node.process_mode = PROCESS_MODE_INHERIT if on else PROCESS_MODE_DISABLED
	for child in node.get_children():
		_toggle(child, on)


func _on_texture_button_pressed():
	if can_switch:
		_switch()
	else:
		print("skill on cooldown")
