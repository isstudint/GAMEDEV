extends AnimatableBody2D

## Friendly robot for the Past timeline — acts as a moving platform.
## Uses AnimatableBody2D (same as the Elevator) so the player rides on top.
## Smart: won't walk off edges when moving horizontally.
## Place inside level_past.tscn under the LevelPast node.

@export var move_speed: float = 40.0
@export var travel_distance: float = 150.0
## "x" = horizontal patrol, "y" = vertical elevator
@export_enum("x", "y") var axis: String = "x"

var start_pos: Vector2
var direction: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_check: RayCast2D = $FloorCheck


func _ready():
	start_pos = global_position
	sprite.play("walk")
	floor_check.target_position = Vector2(16 * direction, 20)


func _physics_process(delta):
	if axis == "x":
		# --- Edge detection: turn around if no floor ahead ---
		if not floor_check.is_colliding():
			direction *= -1

		global_position.x += move_speed * direction * delta
		if global_position.x > start_pos.x + travel_distance:
			direction = -1
		elif global_position.x < start_pos.x - travel_distance:
			direction = 1

		sprite.flip_h = (direction == -1)
		floor_check.target_position.x = 16 * direction

	elif axis == "y":
		global_position.y += move_speed * direction * delta
		if global_position.y > start_pos.y + travel_distance:
			direction = -1
		elif global_position.y < start_pos.y:
			direction = 1
