extends CharacterBody2D

## Hostile robot for the Present timeline.
## Patrols back and forth. Uses Area2D detection zone to spot the player
## (works even when player jumps). Shoots bullets when player is in range.
## Smart: won't walk off edges, faces player, reacts before shooting.
## Place inside level_present.tscn under the LevelPresent node.

# --- Patrol ---
@export var patrol_speed: float = 50.0
@export var patrol_distance: float = 100.0

# --- Shooting ---
@export var bullet_scene: PackedScene  # Assign Bullet.tscn in inspector
@export var shoot_cooldown: float = 1.5

# --- Detection ---
@export var detection_range: float = 150.0

@onready var floor_check: RayCast2D = $FloorCheck
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cooldown_timer: Timer = $ShootCooldownTimer
@onready var bullet_spawn: Marker2D = $BulletSpawnPoint
@onready var walk_sfx: AudioStreamPlayer2D = $WalkSFX
@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSFX
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var direction: int = 1   # 1 = right, -1 = left
var start_x: float
var gravity: float = 980.0
var player_detected: bool = false
var player_ref: CharacterBody2D = null
var react_time: float = 0.4
var alert_timer: float = 0.0
var is_reacting: bool = false


func _ready():
	start_x = global_position.x
	cooldown_timer.wait_time = shoot_cooldown
	floor_check.target_position = Vector2(12 * direction, 20)

	# Connect detection area signals
	$DetectionArea.body_entered.connect(_on_detection_area_body_entered)
	$DetectionArea.body_exited.connect(_on_detection_area_body_exited)


func _on_detection_area_body_entered(body):
	if body is CharacterBody2D and body.is_in_group("player"):
		player_detected = true
		player_ref = body


func _on_detection_area_body_exited(body):
	if body is CharacterBody2D and body.is_in_group("player"):
		player_detected = false
		player_ref = null
		is_reacting = false


func _physics_process(delta):
	# --- Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if player_detected and player_ref:
		# AGGRO: Face and track player
		sprite.material.set_shader_parameter("is_aggro", true)
		if player_ref.global_position.x > global_position.x:
			direction = 1
		else:
			direction = -1

		# Small advance towards player if they are too far
		var dist = abs(player_ref.global_position.x - global_position.x)
		if dist > 80.0:
			velocity.x = patrol_speed * 1.2 * direction
		else:
			velocity.x = 0
			
		# Stop walk sound when engaging player if stationary
		if velocity.x == 0 and walk_sfx and walk_sfx.playing:
			walk_sfx.stop()

		# React delay before first shot
		if not is_reacting and cooldown_timer.is_stopped():
			is_reacting = true
			alert_timer = react_time
			sprite.play("idle")

		if is_reacting:
			alert_timer -= delta
			if alert_timer <= 0:
				is_reacting = false
				_shoot()
		elif not cooldown_timer.is_stopped():
			# Wait for the shoot animation to finish before playing idle
			if sprite.animation != "shoot" or not sprite.is_playing():
				sprite.play("idle")
		else:
			_shoot()
	else:
		is_reacting = false
		sprite.material.set_shader_parameter("is_aggro", false)

		# --- Edge detection: turn around if no floor ahead ---
		if is_on_floor() and not floor_check.is_colliding():
			direction *= -1

		# --- Patrol within distance ---
		velocity.x = patrol_speed * direction
		if global_position.x > start_x + patrol_distance:
			direction = -1
		elif global_position.x < start_x - patrol_distance:
			direction = 1

		sprite.play("walk")
		# Play walk SFX while patrolling
		if walk_sfx and !walk_sfx.playing:
			walk_sfx.pitch_scale = randf_range(0.9, 1.1)
			walk_sfx.play()

	# --- Flip sprite + detection + floor check to match direction ---
	sprite.flip_h = (direction == -1)
	$DetectionArea/CollisionShape2D.position.x = 75 * direction
	floor_check.target_position.x = 12 * direction
	# Move bullet spawn far enough so the bullet doesn't hit the robot itself
	bullet_spawn.position.x = 25 * direction

	move_and_slide()


func _shoot():
	if not cooldown_timer.is_stopped():
		return
	cooldown_timer.start()
	anim_player.play("shoot")
	sprite.play("shoot")
	if shoot_sfx:
		shoot_sfx.play()

	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = bullet_spawn.global_position
		
		# --- Predictive Aiming ---
		# Aim where the player is going to be in 0.25 seconds
		var prediction_factor = 0.25
		var player_vel = 0.0
		if player_ref and "velocity" in player_ref:
			player_vel = player_ref.velocity.x
		
		var target_dir = direction
		if player_ref:
			var predicted_x = player_ref.global_position.x + (player_vel * prediction_factor)
			target_dir = 1 if predicted_x > global_position.x else -1
		
		bullet.direction = target_dir
		get_tree().current_scene.add_child(bullet)
