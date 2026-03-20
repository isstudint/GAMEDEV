extends Node2D

@onready var LevelPast = $LevelPast
@onready var LevelPresent = $LevelPresent

var is_past = true  
# for switching purposes to jaco para malaman mo yung halaga ko 
var can_switch = true 
var switch_cooldown = 3.0


func _ready():
	_apply_timeline_state()


func _input(event):
	if can_switch == false and event.is_action_pressed("switch_time"):
		print("skill on cooldown")
	if event.is_action_pressed("switch_time") and can_switch:  
		switch_timeline()
		

func switch_timeline():
	can_switch = false
	is_past = !is_past
	_apply_timeline_state()
	await get_tree().create_timer(switch_cooldown).timeout
	can_switch = true


func _apply_timeline_state():
	_set_timeline_active(LevelPast, is_past)
	_set_timeline_active(LevelPresent, !is_past)


func _set_timeline_active(level: Node, active: bool):
	level.visible = active
	level.set_process(active)
	level.set_physics_process(active)
	_set_collisions_enabled(level, active)


func _set_collisions_enabled(node: Node, enabled: bool):
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", !enabled)

	for child in node.get_children():
		_set_collisions_enabled(child, enabled)
		
func _on_texture_button_pressed() -> void:
	if can_switch:
		switch_timeline()
	else:
		print("Skill cooldown")
