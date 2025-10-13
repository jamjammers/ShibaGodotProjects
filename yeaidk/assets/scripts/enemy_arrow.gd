class_name EnemyArrow extends RigidBody2D

@export var speed := 800
@export var lifetime := 2.0
func _ready() -> void:
	$killSwitch.wait_time = lifetime

func launch(direction: Vector2) -> void:
	linear_velocity = direction.normalized() * speed
	rotation = direction.angle()
	$killSwitch.start()

func kill() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	print(body.name)
	if body.name == "Player":
		body.hit(body.global_position.x > global_position.x)
		kill()
	elif body.is_in_group("enemy"):
		pass
	else:
		kill()
	pass # Replace with function body.
