extends Node2D

## How fast the gear spins (degrees per second)
@export var spin_speed: float = 150.0
@export var tween_time: float = 0.8
@export var up_down: float = 200.0
@export var bob_speed: float = 2.0

var _start_y: float = 0.0
var direction: float = 1.0
var is_spinning: bool = true
var is_moving: bool = true
var _current_speed: float = 0.0
var _time: float = 0.0

@onready var _sfx = $Gear_sfx
func _ready() -> void:
	_current_speed = spin_speed
	_start_y = position.y


	# Connect the Area2D signal if it exists as a child
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	rotation_degrees += _current_speed * delta
	
	if is_moving:
		_time += delta
		position.y = _start_y + sin(_time * bob_speed) * up_down
	
	_update_gear_sfx()

func _update_gear_sfx() -> void:
	var speed_ratio = abs(_current_speed) / spin_speed
	
	if speed_ratio > 0.05:
		# Re-trigger sound when it finishes (seamless loop)
		if !_sfx.playing:
			_sfx.play()
		# Pitch scales with rotation speed + subtle mechanical wobble for character
		var base_pitch = 0.7 + (speed_ratio * 0.5)
		var wobble = sin(_time * 8.0) * 0.03 * speed_ratio  # Slow mechanical hum
		_sfx.pitch_scale = base_pitch + wobble
		# Volume always strong when spinning
		_sfx.volume_db = 10.0 + (speed_ratio * 4.0)  # 10dB to 14dB
	else:
		if _sfx.playing:
			_sfx.stop()

# Called when something enters the gear's Area2D
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
		
func toggle_spin() -> void:
	is_spinning = !is_spinning
	var tween = create_tween()
	if is_spinning:
		tween.tween_property(self, "_current_speed", spin_speed, tween_time)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	else:
		tween.tween_property(self, "_current_speed", 0.0, tween_time)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	is_moving = !is_moving

func stop_spin() -> void:
	is_spinning = false
	var tween = create_tween()
	tween.tween_property(self, "_current_speed", 0.0, tween_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func stop_moving() -> void:
	is_moving = !is_moving
	
func start_spin() -> void:
	is_spinning = true
	var tween = create_tween()
	tween.tween_property(self, "_current_speed", spin_speed, tween_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
