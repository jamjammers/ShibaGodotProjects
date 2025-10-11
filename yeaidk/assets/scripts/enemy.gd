extends RigidBody2D
var active := false
var target: Node2D = null;
var timer: float = 0.0;

var stored_velocity: Vector2 = Vector2.ZERO

var hp := 3

var test = false

func _physics_process(delta):
	if Input.is_action_just_pressed("test"):
		test = !test
		if test:
			linear_velocity = Vector2.ZERO

	if freeze:
		return
	if test:
		return
	timer -= delta
	queue_redraw()
	attackProcess()

func _draw():
	draw_arc(Vector2.ZERO,
		$detectionArea/triggerCircle.shape.radius,
		0, TAU, 64,
		Color.GREEN if target != null else Color.RED,
		2.0)
	if (active):
		draw_line(Vector2(0, 0), target.global_position - global_position, Color.GREEN if active else Color.RED, 2)

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
	if (result.collider.name != "Player"):
		return

	if (timer > 0):
		return
	active = true
	attack()
	timer = 1

func attack():
	physics_material_override.friction = 0
	linear_velocity /=2

	if (target.position.x > position.x):
		apply_central_force(Vector2(500, -300) * 60)
		# linear_velocity += (Vector2(500, -300));
	else:
		apply_central_force(Vector2(-500, -300) * 60)
		# linear_velocity += (Vector2(-500, -300));

func enterFreeze(freezeState:bool) -> void:
	
	freeze = freezeState
	sleeping = freezeState

	if freezeState:
		stored_velocity = linear_velocity
		linear_velocity = Vector2.ZERO
		gravity_scale = 0
	else:
		stored_velocity = Vector2.ZERO
		linear_velocity = stored_velocity
		gravity_scale = 1

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

@warning_ignore("unused_parameter")
func _on_contact_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner: Node2D = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if (body.name == "Player"):
		body.hit(body.global_position > global_position)
	
	elif(shape_owner.is_in_group("groundTop") and shape_owner.position.y < position.y):
		physics_material_override.friction = 1
	pass # Replace with function body.


func _on_contact_area_entered(area: Area2D) -> void:
	if (area.collision_layer & 32 != 0):
		print("hurt")
		hp -=1
		timer = min(timer +0.25, 1.5)
		var dir = area.global_position > global_position
		sleeping = true
		sleeping = false
		if dir:
			
			linear_velocity=(Vector2(-200, -100))
			apply_central_force(Vector2(-500, -200) * 10)
		else:
			linear_velocity=(Vector2(200, -100))
			apply_central_force(Vector2(500, -200) * 10)
		if (hp <= 0):
			queue_free()
	pass # Replace with function body.
