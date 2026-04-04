extends Label

## Pure Text Debug HUD — Minimalist.
## Toggle with F2.

var player: CharacterBody2D

func _ready() -> void:
	# Label → CanvasLayer (DebugHUD) → Player (CharacterBody2D)
	player = get_parent().get_parent() as CharacterBody2D
	visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		visible = !visible

func _process(_delta: float) -> void:
	if not visible or player == null:
		return

	# --- Animation ---
	var anim_name = "N/A"
	var anim_frame = 0
	var sprite = player.get("PlayerSprite")
	if sprite and sprite is AnimatedSprite2D:
		anim_name = sprite.animation
		anim_frame = sprite.frame

	# --- Timeline ---
	var timeline_str = "N/A"
	var level_handler = player.get_node_or_null("../Level handler")
	if level_handler:
		timeline_str = "PAST" if level_handler.is_past else "PRESENT"

	# --- Stats ---
	var speed = player.velocity.length()
	var h_speed = abs(player.velocity.x)
	var v_speed = player.velocity.y
	var max_spd = player.get("maxSpeed") if player.get("maxSpeed") != null else 0.0
	var facing = "RIGHT" if player.get("wasMovingR") else "LEFT"
	var ground = player.is_on_floor()
	var wall = player.is_on_wall()
	var grav = player.get("gravityActive") if player.get("gravityActive") != null else true
	var jumps = player.get("jumpCount") if player.get("jumpCount") != null else 0
	var jumps_max = player.get("jumps") if player.get("jumps") != null else 0
	var health = player.get("health") if player.get("health") != null else 0
	var pos = player.global_position

	# --- Pure Text Output ---
	var t = ""
	t += "ANIM: %s [%d]\n" % [anim_name, anim_frame]
	t += "TIME: %s\n" % timeline_str
	t += "SPEED: %.0f (H:%.0f V:%.0f)\n" % [speed, h_speed, v_speed]
	t += "MAX SPD: %.0f\n" % max_spd
	t += "FACING: %s\n" % facing
	t += "FLOOR: %s\n" % str(ground)
	t += "WALL: %s\n" % str(wall)
	t += "GRAVITY: %s\n" % str(grav)
	t += "JUMPS: %d/%d\n" % [jumps, jumps_max]
	t += "HEALTH: %d\n" % health
	t += "POS: (%.0f, %.0f)" % [pos.x, pos.y]
	
	text = t
