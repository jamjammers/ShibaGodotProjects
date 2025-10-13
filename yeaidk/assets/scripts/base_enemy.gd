class_name BaseEnemy

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


func _ready() -> void:
	print("Debug: %s enemy is ready"%name)
	$detectionArea.connect("body_entered", Callable(self, "_on_detection_body_entered"))
	$detectionArea.connect("body_exited", Callable(self, "_on_detection_body_exited"))
	$contact.connect("body_shape_entered", Callable(self, "_on_contact_body_shape_entered"))
	$contact.connect("area_entered", Callable(self, "_on_contact_area_entered"))
	physics_material_override.friction = 1.0
	
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
	if target != null:
		draw_line(Vector2(0, 0), target.global_position - global_position, Color.GREEN if active else Color.RED, 2)

func attackProcess():
	active = false
	if target == null:
		return
	# check Line of sight
	var colSize:Vector2 = ($physicalCol.shape as RectangleShape2D).size
	
	if not(attackRayCast(Vector2(colSize.x/2-1, colSize.y/2-1)) or 
		   attackRayCast(Vector2(-colSize.x/2+1, colSize.y/2-1)) or 
		   attackRayCast(Vector2(colSize.x/2, -colSize.y/2)) or 
		   attackRayCast(Vector2(-colSize.x/2, -colSize.y/2))):
		return
	active = true

	if (timer > 0):
		return
	attack()
	timer = maxTimer

func attackRayCast(offset: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var q1 = PhysicsRayQueryParameters2D.create(global_position+offset, target.global_position)
	var q2 = PhysicsRayQueryParameters2D.create(global_position-offset, target.global_position)
	var q3 = PhysicsRayQueryParameters2D.create(global_position+Vector2(offset.x, -offset.y), target.global_position)
	var q4 = PhysicsRayQueryParameters2D.create(global_position-Vector2(offset.x, -offset.y), target.global_position)
	
	var layers = 1+2+pow(2,5)

	q1.collision_mask = layers
	q2.collision_mask = layers
	q3.collision_mask = layers
	q4.collision_mask = layers

	var r1 = space_state.intersect_ray(q1)
	var r2 = space_state.intersect_ray(q2)
	var r3 = space_state.intersect_ray(q3)
	var r4 = space_state.intersect_ray(q4)

	print("Raycast results: ", r1.is_empty(), r2.is_empty(), r3.is_empty(), r4.is_empty())
	if !(r1 or r2 or r3 or r4):
		return false
	if (
			(!r1.is_empty() and r1.collider.name != target.name) or 
			(!r2.is_empty() and r2.collider.name != target.name) or 
			(!r3.is_empty() and r3.collider.name != target.name) or 
			(!r4.is_empty() and r4.collider.name != target.name)
		):
		return false
	return true

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
	if body.name == "Player":
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
		physics_material_override.friction = 1
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
