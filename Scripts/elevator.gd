# elevator.gd
extends AnimatableBody2D

@export var move_distance: float = 140.0
@export var move_speed: float = 100.0

var start_position: Vector2
var target_position: Vector2

enum State { IDLE_TOP, GOING_DOWN, IDLE_BOTTOM, GOING_UP }
var current_state = State.IDLE_TOP

func _ready():
	start_position = global_position
	target_position = start_position + Vector2(0, move_distance)
	
	$DetectionArea.body_entered.connect(_on_player_entered)

func _physics_process(delta):
	match current_state:
		State.GOING_DOWN:
			global_position = global_position.move_toward(target_position,move_speed * delta)
			if global_position.distance_to(target_position) < 1.0:
				global_position = target_position
				current_state = State.IDLE_BOTTOM 

		State.GOING_UP:
			global_position = global_position.move_toward(start_position,move_speed * delta)
			if global_position.distance_to(start_position) < 1.0:
				global_position = start_position
				current_state = State.IDLE_TOP 

func _on_player_entered(body):
	if body.is_in_group("player"):
		if current_state == State.IDLE_TOP:
			current_state = State.GOING_DOWN
		elif current_state == State.IDLE_BOTTOM:
			current_state = State.GOING_UP
