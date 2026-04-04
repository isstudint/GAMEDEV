# moving_platform.gd — Horizontal moving platform with tween-based movement
extends AnimatableBody2D

## Horizontal moving platform — tweens left and right smoothly.
## Player can stand on it and ride. Same base as the Elevator.

@export var move_distance: float = 150.0
@export var move_speed: float = 60.0
## Pause at each end before going back
@export var wait_time: float = 0.3


func _ready():
	_start_tween()


func _start_tween():
	var start_pos = global_position
	var end_pos = start_pos + Vector2(move_distance, 0)
	var duration = move_distance / move_speed

	var tween = create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "global_position", end_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(wait_time)
	tween.tween_property(self, "global_position", start_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(wait_time)
