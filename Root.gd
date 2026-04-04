extends Node2D

@onready var LevelPast = $LevelPast
@onready var LevelPresent = $LevelPresent

var is_past = false
var can_switch = true
var switch_cooldown = 0
var number_of_switching = 5.0

# ============================================================
# CUSTOMIZATION — Tweak in Inspector > "Remote" tab for live testing
# ============================================================

@export_group("Timing")
@export var TRANSITION_TIME: float = 0.4   # Total transition length (seconds)
@export var FLASH_TIME: float = 0.05       # Blink-fast flash duration

@export_group("Ripple Wave")
@export_range(0.0, 0.15) var RIPPLE_DISTORTION: float = 0.045 # How much the wave bends pixels
@export_range(0.02, 0.3) var RIPPLE_WIDTH: float = 0.08       # Thickness of the ripple ring

@export_group("Subtle Glitch")
@export_range(0.0, 0.05) var GLITCH_STRENGTH: float = 0.012   # Horizontal slice shift
@export_range(0.0, 0.02) var RGB_SPLIT: float = 0.005         # Color channel separation

@export_group("Timeline Colors — tints the actual game world")
@export var PAST_COLOR: Color = Color(1.15, 1.05, 0.88)       # Warm amber
@export var PRESENT_COLOR: Color = Color(0.88, 0.95, 1.12)    # Cool blue


# ============================================================
# TRANSITION SHADER
# Handles: ripple wave + subtle glitch + quick flash
# ============================================================
var _shader_code = """
shader_type canvas_item;

// Reads what's currently on screen so we can distort it
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// --- Ripple uniforms (tweened by GDScript) ---
uniform float ripple_progress : hint_range(0.0, 2.0) = 0.0;  // how far the ring has expanded
uniform vec2 ripple_center = vec2(0.5, 0.5);                  // where the ripple starts (player pos)
uniform float ripple_distortion = 0.045;                       // wave bend strength
uniform float ripple_width = 0.08;                             // ring thickness
uniform float aspect_ratio = 1.78;                             // corrects for non-square screens

// --- Glitch uniforms (tweened by GDScript) ---
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;  // master glitch amount
uniform float glitch_strength = 0.012;                         // horizontal shift pixels
uniform float rgb_split = 0.005;                               // color separation distance

// --- Flash uniform (tweened by GDScript) ---
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;   // white blink amount

// Pseudo-random hash — turns any vec2 into a "random" float between 0-1
float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// === RIPPLE WAVE ===
	// Make the ripple circular by correcting for screen aspect ratio
	vec2 corrected_uv = vec2(uv.x * aspect_ratio, uv.y);
	vec2 corrected_center = vec2(ripple_center.x * aspect_ratio, ripple_center.y);
	float dist = distance(corrected_uv, corrected_center);

	// How far this pixel is from the expanding ring edge
	float ring_dist = dist - ripple_progress;
	// Smooth falloff — pixels near the ring edge get distorted, others don't
	float wave = smoothstep(ripple_width, 0.0, abs(ring_dist));
	// Push pixels outward with a sine oscillation (creates the "water ripple" look)
	vec2 dir = normalize(uv - ripple_center + vec2(0.001)); // +0.001 prevents divide-by-zero
	uv += dir * wave * ripple_distortion * sin(ring_dist * 40.0);

	// === SUBTLE GLITCH ===
	// Chop screen into horizontal bands, randomly shift some left/right
	float time_seed = TIME * 12.0;
	float slice = floor(uv.y * 30.0) / 30.0;
	float shift = rand(vec2(slice, time_seed)) * 2.0 - 1.0;  // random direction (-1 to 1)
	float mask = step(0.7, rand(vec2(slice, time_seed + 1.0))); // only 30% of slices move
	uv.x += shift * mask * glitch_strength * glitch_intensity;

	// === RGB SPLIT (chromatic aberration) ===
	// Sample red/green/blue from slightly offset positions
	float split = rgb_split * glitch_intensity;
	float r = texture(screen_texture, uv + vec2(split, 0.0)).r;  // red shifts right
	float g = texture(screen_texture, uv).g;                      // green stays centered
	float b = texture(screen_texture, uv - vec2(split, 0.0)).b;  // blue shifts left
	vec4 color = vec4(r, g, b, 1.0);

	// === FLASH (white blink) ===
	// Blends toward pure white — fast in, fast out
	color.rgb = mix(color.rgb, vec3(1.0), flash_intensity);

	COLOR = color;
}
"""


func _ready():
	_apply_timeline()


func _input(event):
	if event.is_action_pressed("switch_time"):
		if can_switch:
			_switch()
		else:
			print("skill on cooldown")


# Finds the Player's position on screen and converts to UV (0-1) for the shader
func _get_ripple_center() -> Vector2:
	var player = get_parent().get_node_or_null("Player")
	if player and player is Node2D:
		var canvas_xform = get_viewport().get_canvas_transform()
		var screen_pos = canvas_xform * player.global_position
		var vp_size = get_viewport().get_visible_rect().size
		return Vector2(screen_pos.x / vp_size.x, screen_pos.y / vp_size.y)
	return Vector2(0.5, 0.5) # fallback: center of screen


func _switch():
	can_switch = false

	# --- Build fullscreen overlay ---
	var layer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	var rect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)

	# --- Attach transition shader ---
	var mat = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = _shader_code
	mat.shader = shader

	# Pass customization values into the shader
	mat.set_shader_parameter("ripple_distortion", RIPPLE_DISTORTION)
	mat.set_shader_parameter("ripple_width", RIPPLE_WIDTH)
	mat.set_shader_parameter("glitch_strength", GLITCH_STRENGTH)
	mat.set_shader_parameter("rgb_split", RGB_SPLIT)
	mat.set_shader_parameter("ripple_center", _get_ripple_center())

	# Fix aspect ratio so ripple is a circle, not an oval
	var vp_size = get_viewport().get_visible_rect().size
	mat.set_shader_parameter("aspect_ratio", vp_size.x / vp_size.y)

	rect.material = mat

	var half = TRANSITION_TIME * 0.5

	# ===== PHASE 1: Reality breaking (first half) =====
	# Ripple starts expanding from player + subtle glitch ramps up
	var tween = create_tween().set_parallel(true)
	tween.tween_method(
		func(v): mat.set_shader_parameter("ripple_progress", v),
		0.0, 0.6, half
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(v): mat.set_shader_parameter("glitch_intensity", v),
		0.0, 1.0, half
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished

	# ===== FLASH + SWAP =====
	# Quick blink to white (hides the actual swap)
	tween = create_tween()
	tween.tween_method(
		func(v): mat.set_shader_parameter("flash_intensity", v),
		0.0, 0.7, FLASH_TIME * 0.5
	)
	await tween.finished

	# >>> SWAP happens at peak flash — player doesn't see the cut <<<
	is_past = !is_past
	_apply_timeline()

	tween = create_tween()
	tween.tween_method(
		func(v): mat.set_shader_parameter("flash_intensity", v),
		0.7, 0.0, FLASH_TIME * 0.5
	)
	await tween.finished

	# ===== PHASE 2: New reality settling (second half) =====
	# Ripple continues expanding out + glitch fades away
	tween = create_tween().set_parallel(true)
	tween.tween_method(
		func(v): mat.set_shader_parameter("ripple_progress", v),
		0.6, 1.5, half
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(v): mat.set_shader_parameter("glitch_intensity", v),
		1.0, 0.0, half
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

	# Done — remove the overlay
	layer.queue_free()

	await get_tree().create_timer(switch_cooldown).timeout
	can_switch = true


func _apply_timeline():
	_toggle(LevelPast, is_past)
	_toggle(LevelPresent, !is_past)
	# Tint each timeline's world with its color
	LevelPast.modulate = PAST_COLOR
	LevelPresent.modulate = PRESENT_COLOR


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
