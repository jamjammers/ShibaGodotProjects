class_name Enemy

extends RigidBody2D

var active := false
var target: Node2D = null;

## attack spd timers
var timer: float = 0.0;
@export var maxTimer: float = 1.0;

## this is only if you contact damage want
@export var contactDamage := true

var stored_velocity: Vector2 = Vector2.ZERO

var hp := 3

var test = false



func _process(delta):
	if Input.is_action_just_pressed("test"):
		test = !test
		if test:
			linear_velocity = Vector2.ZERO

	if freeze:
		return
	if test:
		return
	if (active):
		timer -= delta
	elif(timer > maxTimer/4):
		timer = max(timer - delta, maxTimer/4)
	queue_redraw()
	attackProcess()

func _draw():
	draw_arc(Vector2.ZERO,
		$detectionArea/triggerCircle.shape.radius,
		0, TAU, 64,
		Color.GREEN if target != null else Color.RED,
		2.0)

func attackProcess():
	active = false
	if target == null:
		return
	# check Line of sight
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if !result:
		return
	if (result.collider.name != target.name):
		return
	active = true

	if (timer > 0):
		return
	attack()
	timer = maxTimer

func attack():
	pass # MUSI IMPLEMENT

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
	if body.name == "Player": # maybe change later?
		active = true
		target = body;
		
		queue_redraw()

func _on_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		active = false
		target = null
		
		queue_redraw()

@warning_ignore("unused_parameter")
func _on_contact_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner: Node2D = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if (body.name == "Player" and contactDamage):
		body.hit(body.global_position > global_position)
	
	elif(shape_owner.is_in_group("groundTop") and shape_owner.position.y < position.y):
		# physics_material_override.friction = 1
		pass
	pass # Replace with function body.


func _on_contact_area_entered(area: Area2D) -> void:
	if (area.collision_layer & 32 != 0):
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
