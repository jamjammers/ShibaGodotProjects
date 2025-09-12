extends RigidBody2D

@export var speed = 600.0
@export var acceleration = 6000.0
@export var friction = 6000.0

var airborne := false
var jumping := false
func _process(_delta: float) -> void:
	
	#jump initial
	if Input.is_action_just_pressed("jump") and (not airborne):
		apply_central_impulse(Vector2(0, -1000))
		jumping = true

func _physics_process(delta):
	
	#jumpy floaty
	if !Input.is_action_pressed("jump") or linear_velocity.y > 0:
		jumping = false
	elif jumping:
		apply_central_force(Vector2(0, -1000))
	var input_dir = Input.get_axis("moveLeft", "moveRight")
	
	if input_dir != 0:
		# Accelerate toward target speed
		linear_velocity.x = move_toward(linear_velocity.x, input_dir * speed, acceleration * delta)
	else:
		# Friction when no input
		linear_velocity.x = move_toward(linear_velocity.x, 0, friction * delta)



func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner :Node = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if(shape_owner.is_in_group("groundTop")):
		#print(" grounded")
		airborne = false


func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner :Node = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if(shape_owner.is_in_group("groundTop")):
		#print(" not grounded")
		airborne = true
