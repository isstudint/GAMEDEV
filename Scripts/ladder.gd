# ladder.gd — A ladder that gets dropped/rotated by a Lever
# Rotates around the Node2D's position (the pivot point).
# Just move the Ladder node in the editor to set the pivot.
extends Node2D

## How many degrees the ladder rotates when dropped
@export var fall_angle: float = 90.0
## How long the rotation animation takes
@export var fall_time: float = 0.8

var is_fallen: bool = false

func drop() -> void:
	if is_fallen:
		return
	is_fallen = true
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", fall_angle, fall_time)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
