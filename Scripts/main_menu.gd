extends Control

## Main Menu — Dual-timeline title flash with full-screen glitch effects.

@onready var title_clean: Label = $TitleClean
@onready var title_corrupt: Label = $TitleCorrupt
@onready var subtitle: Label = $Subtitle
@onready var start_btn: Button = $VBoxContainer/StartButton
@onready var settings_btn: Button = $VBoxContainer/SettingsButton
@onready var quit_btn: Button = $VBoxContainer/QuitButton
@onready var dark_overlay: ColorRect = $DarkOverlay

var subtitle_clean_text: String = "Fixing the past. Save the present."
var subtitle_corrupt_text: String = "THE PAST IS BROKEN."
var overlay_normal_color: Color = Color(0, 0, 0, 0.5)
var overlay_glitch_color: Color = Color(0.15, 0.0, 0.0, 0.55)


func _ready():
	start_btn.pressed.connect(_on_start_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

	# Button hover effects
	for btn in [start_btn, settings_btn, quit_btn]:
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))

	title_clean.visible = true
	title_corrupt.visible = false
	subtitle.text = subtitle_clean_text

	_play_intro()
	_glitch_loop()
	_ambient_loop()


func _play_intro():
	# Hide everything
	title_clean.modulate.a = 0.0
	subtitle.modulate.a = 0.0

	var buttons = [start_btn, settings_btn, quit_btn]
	for btn in buttons:
		btn.modulate.a = 0.0
		btn.position.x -= 40

	# Fade in background (already handled by the instanced scene, so just wait briefly)
	await get_tree().create_timer(0.2).timeout

	# Title fade in
	await get_tree().create_timer(0.5).timeout
	var t = create_tween()
	t.tween_property(title_clean, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT)
	await t.finished

	# Quick glitch flash on first appearance
	await get_tree().create_timer(0.3).timeout
	_do_glitch_flash(0.15)

	# Subtitle
	await get_tree().create_timer(0.4).timeout
	var t2 = create_tween()
	t2.tween_property(subtitle, "modulate:a", 0.7, 0.6)

	# Stagger buttons
	await get_tree().create_timer(0.3).timeout
	for btn in buttons:
		await get_tree().create_timer(0.12).timeout
		var tw = create_tween().set_parallel()
		tw.tween_property(btn, "modulate:a", 1.0, 0.35)
		tw.tween_property(btn, "position:x", btn.position.x + 40, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _ambient_loop():
	pass


func _glitch_loop():
	await get_tree().create_timer(3.0).timeout

	while true:
		# Wait in clean state
		await get_tree().create_timer(randf_range(2.5, 6.0)).timeout
		_do_glitch_flash(randf_range(0.08, 0.2))

		# Random chance for double or triple flash
		var extra_flashes = randi_range(0, 2)
		for i in range(extra_flashes):
			await get_tree().create_timer(randf_range(0.04, 0.1)).timeout
			_do_glitch_flash(randf_range(0.05, 0.12))


func _do_glitch_flash(duration: float):
	# --- CORRUPT STATE ---
	title_clean.visible = false
	title_corrupt.visible = true
	title_corrupt.position.x = title_clean.position.x + randf_range(-6, 6)
	title_corrupt.position.y = title_clean.position.y + randf_range(-3, 3)

	# Corrupt the subtitle
	subtitle.text = subtitle_corrupt_text
	subtitle.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2, 0.7))

	# Flash the screen overlay red
	dark_overlay.color = overlay_glitch_color

	# Hold
	await get_tree().create_timer(duration).timeout

	# --- CLEAN STATE ---
	title_corrupt.visible = false
	title_clean.visible = true

	subtitle.text = subtitle_clean_text
	subtitle.add_theme_color_override("font_color", Color(0.55, 0.6, 0.75, 0.7))

	dark_overlay.color = overlay_normal_color


func _on_button_hover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "position:x", btn.position.x + 8, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_button_unhover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "position:x", btn.position.x - 8, 0.15).set_trans(Tween.TRANS_SINE)


func _on_start_pressed():
	# Rapid glitch burst then white flash
	for i in range(5):
		_do_glitch_flash(0.04)
		await get_tree().create_timer(0.06).timeout

	var flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash)

	var tween = create_tween()
	tween.tween_property(flash, "color:a", 1.0, 0.25)
	tween.tween_interval(0.15)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://Scenes/Main.tscn"))


func _on_settings_pressed():
	print("Settings pressed")


func _on_quit_pressed():
	get_tree().quit()
