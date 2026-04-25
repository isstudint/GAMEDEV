# friendly_robot.gd — Revamped friendly robot for Past timeline
# Acts as a moving platform. Can be blocked by crates.
# Has idle/walk animations and edge detection.
extends AnimatableBody2D

@export var move_speed: float = 40.0
@export var travel_distance: float = 150.0
## "x" = horizontal patrol, "y" = vertical elevator
@export_enum("x", "y") var axis: String = "x"

## If true, the robot stops when something blocks its path (like a crate)
@export var can_be_blocked: bool = true

var start_pos: Vector2
var direction: int = 1
var is_blocked: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_check: RayCast2D = $FloorCheck
@onready var wall_check: RayCast2D = $WallCheck

func _ready():
	start_pos = global_position
	sprite.play("walk")
	floor_check.target_position = Vector2(16 * direction, 20)
	
	# Create wall check if it doesn't exist
	if not has_node("WallCheck"):
		var wc = RayCast2D.new()
		wc.name = "WallCheck"
		add_child(wc)
		wall_check = wc
	
	_update_raycasts()

func _physics_process(delta):
	if axis == "x":
		_update_raycasts()
		
		# --- Edge detection: turn around if no floor ahead ---
		if not floor_check.is_colliding():
			direction *= -1
			_update_raycasts()
		
		# --- Crate/wall blocking ---
		if can_be_blocked and wall_check and wall_check.is_colliding():
			var collider = wall_check.get_collider()
			if collider is RigidBody2D:  # It's a crate!
				is_blocked = true
				sprite.play("idle")
				return
			else:
				# Hit a wall, turn around
				direction *= -1
				_update_raycasts()
		
		is_blocked = false
		sprite.play("walk")
		
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

func _update_raycasts():
	if floor_check:
		floor_check.target_position.x = 16 * direction
	if wall_check:
		wall_check.target_position = Vector2(14 * direction, -8)
