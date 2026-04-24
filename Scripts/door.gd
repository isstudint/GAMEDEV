extends Node2D

@export var target_door: NodePath  #d

#Teleport door 2 door
# Basta makuha lang yung pos ng 2nd door

var can_teleport = true #iwas jitter

# Reference the node from the scene — drag DoorSFX node here in inspector
@onready var _sfx: AudioStreamPlayer2D = $DoorSFX

func _ready():
	pass

func _on_body_entered(body):
	if body.name != "Player": return
	if not can_teleport: return

	if target_door == null:return

	var door_node = get_node(target_door)
	if door_node == null: 
		return
	can_teleport = false
	door_node.can_teleport = false

	# Play door SFX at this door
	if _sfx:
		_sfx.pitch_scale = randf_range(0.95, 1.05)
		_sfx.play()

	body.global_position = door_node.global_position
	await get_tree().create_timer(0.2).timeout
	can_teleport = true
	door_node.can_teleport = true
