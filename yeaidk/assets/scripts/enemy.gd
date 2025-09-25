extends RigidBody2D
var active := false
var target: Node2D = null;
var timer : float = 0.0;

func _physics_process(delta):
	timer -= delta
	queue_redraw()
	attackProcess()

func _draw():
	draw_arc(Vector2.ZERO, 
		$detectionArea/triggerCircle.shape.radius, 
		0, TAU, 64, 
		Color.GREEN if target != null else Color.RED,
		2.0)
	if(active):
		draw_line(Vector2(0,0), target.global_position-global_position, Color.GREEN if active else Color.RED,2 )

func attackProcess():
	active = false
	if target == null:
		return

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if !result:
		return
	if(result.collider.name!="Player"):
		return

	if(timer > 0):
		return
	active = true
	attack()
	timer = 2
func attack():
	if(target.position.x > position.x):
		apply_central_impulse(Vector2(500,-300));
	else:
		apply_central_impulse(Vector2(-500,-300));

func _on_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		active = true
		target = body;
		timer = maxf(timer, 0.1)
		
		queue_redraw()

func _on_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		active = false
		target = null
		
		queue_redraw()

func _on_contact_body_entered(body: Node2D) -> void:
	if( body.name == "Player"):
		body.hit()

	pass # Replace with function body.
