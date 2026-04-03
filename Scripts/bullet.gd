extends Area2D

## Projectile fired by the EnemyRobot.
## Moves horizontally, calls take_damage() on the player, self-destructs off-screen.

var speed: float = 300.0
var direction: int = 1   # 1 = right, -1 = left
var damage: int = 1


func _physics_process(delta):
	position.x += speed * direction * delta


func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
