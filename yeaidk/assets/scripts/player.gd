extends RigidBody2D

signal hurt(hp:int)

@export var speed = 600.0
@export var acceleration = 6000.0
@export var friction = 6000.0

var airborne := false
var jumping := false

var hp :=5

var universalTimer := 0.0 # universal delta stuff


var abilities:= {"dash":true};
var dashed := false #can only dash once per airborne state
var facing : int;

func _process(delta: float) -> void:
	universalTimer += delta
	#jump initial
	jump()
	
	dash()

func _physics_process(delta):
	#jumpy floaty
	jumpCont()
	
	horizMovement(delta)



# main boost of jump + logic
func jump():
	if Input.is_action_just_pressed("jump") and (not airborne):
		apply_central_impulse(Vector2(0, -1000))
		jumping = true

func dash():
	if(!abilities.dash):
		return
	if !$dashTimer.is_stopped():
		return
	if !Input.is_action_just_pressed("dash"):
		return
	if airborne:
		dashed = true
	linear_velocity.y = -200;
		
	apply_central_impulse(Vector2(1700 * facing,0))
	$dashTimer.start();

# continuation of the jump + logic
func jumpCont():
	if !Input.is_action_pressed("jump") or linear_velocity.y > 0:
		jumping = false
	elif jumping:
		apply_central_force(Vector2(0, -1000))

# horizontal movement + logic
func horizMovement(delta):
	var input_dir = Input.get_axis("moveLeft", "moveRight")
	if input_dir != 0:
		# Accelerate toward target speed
		facing = int(input_dir/abs(input_dir));
		linear_velocity.x = move_toward(linear_velocity.x, input_dir * speed, acceleration * delta)
	else:
		# Friction when no input
		linear_velocity.x = move_toward(linear_velocity.x, 0, friction * delta)

@warning_ignore("unused_parameter")
func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner : Node = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	
	if(shape_owner.is_in_group("groundTop")):
		#print(" grounded")
		airborne = false
		

func hit():
	hp-=1
	hurt.emit(hp)
	print(hp)


@warning_ignore("unused_parameter")
func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner :Node = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if(shape_owner.is_in_group("groundTop")):
		#print(" not grounded")
		airborne = true
