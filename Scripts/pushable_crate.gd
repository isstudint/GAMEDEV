# pushable_crate.gd — A crate the player can push by walking into it
# Uses RigidBody2D so it has gravity and falls off ledges naturally.
extends RigidBody2D

## How heavy the crate feels (higher = harder to push)
@export var crate_mass: float = 2.0

func _ready():
	mass = crate_mass
	lock_rotation = true
	gravity_scale = 1.0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	# Start unfrozen so it responds to physics
	freeze = false
	
	# Prevent the crate from sliding forever
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.9
	physics_material_override.bounce = 0.0
