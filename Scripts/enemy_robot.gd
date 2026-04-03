extends CharacterBody2D

## Hostile robot for the Present timeline.
## Patrols back and forth. Uses RayCast2D to detect the player and shoots bullets.
## Place inside level_present.tscn under the LevelPresent node.

# --- Patrol ---
@export var patrol_speed: float = 50.0
@export var patrol_distance: float = 100.0

# --- Shooting ---
@export var bullet_scene: PackedScene  # Assign Bullet.tscn in inspector
@export var shoot_cooldown: float = 1.5

# --- Detection ---
@export var detection_range: float = 150.0

@onready var ray: RayCast2D = $RayCast2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cooldown_timer: Timer = $ShootCooldownTimer
@onready var bullet_spawn: Marker2D = $BulletSpawnPoint

var direction: int = 1   # 1 = right, -1 = left
var start_x: float
var gravity: float = 980.0
var player_detected: bool = false


func _ready():
	start_x = global_position.x
	cooldown_timer.wait_time = shoot_cooldown
	ray.target_position.x = detection_range * direction


func _physics_process(delta):
	# --- Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# --- Detection via RayCast ---
	player_detected = false
	if ray.is_colliding():
		var collider = ray.get_collider()
		# Player uses PlatformerController2D which extends CharacterBody2D
		if collider is CharacterBody2D and collider.is_in_group("player"):
			player_detected = true

	if player_detected:
		_shoot()
		velocity.x = 0
		sprite.play("idle")
	else:
		# --- Patrol ---
		velocity.x = patrol_speed * direction
		if global_position.x > start_x + patrol_distance:
			direction = -1
		elif global_position.x < start_x - patrol_distance:
			direction = 1
		sprite.play("walk")

	# --- Flip sprite + raycast to match direction ---
	sprite.flip_h = (direction == -1)
	ray.target_position.x = detection_range * direction
	bullet_spawn.position.x = abs(bullet_spawn.position.x) * direction

	move_and_slide()


func _shoot():
	if not cooldown_timer.is_stopped():
		return
	cooldown_timer.start()
	sprite.play("shoot")

	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = bullet_spawn.global_position
		bullet.direction = direction
		# Add to the scene root so bullets persist even if the robot is freed
		get_tree().current_scene.add_child(bullet)
