# puzzle_state.gd — Autoload singleton that tracks puzzle progress
# This persists across timeline switches since it's NOT inside LevelPast/LevelPresent
extends Node

## Signals for objects to react to state changes
signal power_core_collected
signal generator_powered
signal power_rerouted
signal puzzle_complete

## State
var has_power_core: bool = false
var is_generator_powered: bool = false
var is_power_rerouted: bool = false

func collect_power_core():
	has_power_core = true
	power_core_collected.emit()
	print("[PuzzleState] Power Core collected!")

func power_generator():
	if has_power_core:
		is_generator_powered = true
		has_power_core = false  # Core is now IN the generator
		generator_powered.emit()
		print("[PuzzleState] Generator powered on!")
		_check_complete()

func reroute_power():
	is_power_rerouted = true
	power_rerouted.emit()
	print("[PuzzleState] Power rerouted to exit!")
	_check_complete()

func _check_complete():
	if is_generator_powered and is_power_rerouted:
		puzzle_complete.emit()
		print("[PuzzleState] ★ PUZZLE COMPLETE — Exit unlocked! ★")

func reset():
	has_power_core = false
	is_generator_powered = false
	is_power_rerouted = false
