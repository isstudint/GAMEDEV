extends AnimatableBody2D

## Friendly robot for the Past timeline — acts as a moving platform.
## Uses AnimatableBody2D (same as the Elevator) so the player rides on top.
## Place inside level_past.tscn under the LevelPast node.

@export var move_speed: float = 40.0
@export var travel_distance: float = 150.0
## "x" = horizontal patrol, "y" = vertical elevator
@export_enum("x", "y") var axis: String = "x"

var start_pos: Vector2
var direction: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	start_pos = global_position
	sprite.play("walk")


func _physics_process(delta):
	if axis == "x":
		global_position.x += move_speed * direction * delta
		if global_position.x > start_pos.x + travel_distance:
			direction = -1
		elif global_position.x < start_pos.x - travel_distance:
			direction = 1
		sprite.flip_h = (direction == -1)
	elif axis == "y":
		global_position.y += move_speed * direction * delta
		if global_position.y > start_pos.y + travel_distance:
			direction = -1
		elif global_position.y < start_pos.y:
			direction = 1
