extends Enemy


func attack():
	physics_material_override.friction = 0
	linear_velocity /=2

	if (target.position.x > position.x):
		apply_central_force(Vector2(500, -300) * 60)
	else:
		apply_central_force(Vector2(-500, -300) * 60)
