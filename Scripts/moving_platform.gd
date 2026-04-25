# moving_platform.gd — Moving platform that can run continuously or be lever-activated
extends AnimatableBody2D

## How far the platform moves from its start position
@export var move_distance: float = 150.0
## Speed of the platform movement
@export var move_speed: float = 60.0
## Pause at each end before going back
@export var wait_time: float = 0.3

## CONTINUOUS = starts moving on its own, loops forever
## LEVER = starts stopped, waits for activate() call from a lever
@export_enum("Continuous", "Lever") var mode: int = 0

var is_active: bool = false
var _tween: Tween = null
var _start_pos: Vector2

func _ready():
	_start_pos = global_position
	if mode == 0:  # Continuous
		is_active = true
		_start_tween()


func activate():
	## Called by the lever to start/stop the platform
	if is_active:
		# Stop the platform
		is_active = false
		if _tween:
			_tween.kill()
			_tween = null
	else:
		# Start the platform
		is_active = true
		_start_pos = global_position
		_start_tween()


func _start_tween():
	var end_pos = _start_pos + Vector2(0, move_distance)
	var duration = move_distance / move_speed

	_tween = create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "global_position", end_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(wait_time)
	_tween.tween_property(self, "global_position", _start_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(wait_time)
