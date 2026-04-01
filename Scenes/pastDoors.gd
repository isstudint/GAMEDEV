extends Area2D

@export var teleport_target: Vector2 = Vector2(0, 0)
var can_teleport = false

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(2.0).timeout
	can_teleport = true

func _on_body_entered(body):
	print("something entered: ", body.name)
	if body.is_in_group("player") and can_teleport:
		print("teleporting!")
		can_teleport = false
		body.global_position = teleport_target
		await get_tree().create_timer(2.0).timeout
		can_teleport = true
