extends "res://assets/scripts/enemy.gd"

func _draw():
	super._draw()

	if target != null:
		draw_line(Vector2(0, 0), target.global_position - global_position, Color.GREEN if active else Color.RED, 2)

func attack():
	physics_material_override.friction = 0
	linear_velocity /=2

	if (target.position.x > position.x):
		apply_central_force(Vector2(500, -300) * 60)
	else:
		apply_central_force(Vector2(-500, -300) * 60)
