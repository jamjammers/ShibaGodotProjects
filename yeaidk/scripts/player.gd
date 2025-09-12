extends RigidBody2D


var airborne := true
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		apply_central_force(Vector2(500, 0))
	
	pass
