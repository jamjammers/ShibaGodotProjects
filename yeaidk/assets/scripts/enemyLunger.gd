extends EnemyBase

func _ready() -> void:
	super._ready();
	hp = 5

func attack():
	physics_material_override.friction = 0

	if (target.position.x > position.x):
		apply_central_force(Vector2(500, -300) * 60)
	else:
		apply_central_force(Vector2(-500, -300) * 60)
