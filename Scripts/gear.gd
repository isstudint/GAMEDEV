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

func _ready() -> void:
	_current_speed = spin_speed
	_start_y = position.y     

func _process(delta: float) -> void:
	rotation_degrees += _current_speed * delta
	
	if is_moving:
		_time += delta
		position.y = _start_y + sin(_time * bob_speed) * up_down
	

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
