extends RigidBody2D
var active := false
var target: Node2D = null;
var timer : float = 0.0;

signal hit

func _physics_process(delta):
	timer -= delta
	if(active and timer <0):
		attack()
		timer = 2

func _draw():
	draw_arc(Vector2.ZERO, 
		$detectionArea/triggerCircle.shape.radius, 
		0, TAU, 64, 
		Color.GREEN if active else Color.RED,
		2.0)


func attack():
	if(target.position.x > position.x):
		apply_central_impulse(Vector2(500,-300));
	else:
		apply_central_impulse(Vector2(-500,-300));

func _on_detection_body_entered(body: Node2D) -> void:
	print(body.name+ " found")
	if body.name == "Player":
		active = true
		target = body;
		timer = maxf(timer, 0.1)
		
		queue_redraw()

func _on_detection_body_exited(body: Node2D) -> void:
	print(body.name+" lose")

	if body.name == "Player":
		active = false
		target = null
		
		queue_redraw()


func _on_contact_body_entered(body: Node2D) -> void:
	if( body.name == "Player"):
		body.hit()

	pass # Replace with function body.
