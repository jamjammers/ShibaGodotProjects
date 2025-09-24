extends RigidBody2D

signal hurt(hp:int)

@export var speed = 600.0
@export var acceleration = 6000.0
@export var friction = 6000.0

var groundTouching := 0
var jumping := 0
var wallTouch := false
var wallAsim := false

var hp :=5

var universalTimer := 0.0 # universal delta stuff

var abilities:= {"dash":true, "double_jump":true, "wall_attach":true};
var dashed := false #can only dash once per groundTouching state
var doubleJumped := false #can only double once per groundTouching
var facing : int;

func _process(delta: float) -> void:
	universalTimer += delta

	wallAttachCheck()

	if(wallAsim):
		wallJump()
	else:
		jump()
		
		dash()

func _physics_process(delta):
	
	#jumpy floaty
	jumpCont()
	if(wallAsim):
		pass
	else:
		horizMovement(delta)

# set wall Asim if pass checks
func wallAttachCheck():
	if !Input.is_action_just_pressed("wallAttach") :
		return
	if !wallTouch:
		return
	if !abilities.wall_attach:
		return
	wallAsim = !wallAsim
	linear_velocity .y = 0
	gravity_scale = 0 if wallAsim else 3

# main boost of jump + logic
func jump():
	if(!Input.is_action_just_pressed("jump")):
		return

	if (groundTouching):
		apply_central_impulse(Vector2(0, -1000))
		jumping = -500
	elif(!doubleJumped):
		linear_velocity.y = -100
		apply_central_impulse(Vector2(0, -1000))

		doubleJumped = true;

# wall jump + logic
func wallJump():
	if !Input.is_action_just_pressed("jump"):
		return
	var inputDir = Input.get_axis("moveLeft", "moveRight")
	linear_velocity.y = 0
	var mult = inputDir if inputDir == facing else 0.0
	apply_central_impulse(Vector2(mult*800, -1000))
	doubleJumped = false;
	jumping = -500
	wallAsim = false
	gravity_scale = 0 if wallAsim else 3

# dash + logic
func dash():
	if(!abilities.dash or dashed):
		return
	if !$dashTimer.is_stopped():
		return
	if !Input.is_action_just_pressed("dash"):
		return
	if !groundTouching:
		dashed = true
	print(dashed)
	linear_velocity.y = -200;
	
	apply_central_impulse(Vector2(1700 * facing,0))
	$dashTimer.start();

# continuation of the jump + logic
func jumpCont():
	if !Input.is_action_pressed("jump") or linear_velocity.y > 0 or wallAsim:
		jumping = 0
	elif(jumping):
		apply_central_force(Vector2(0, jumping))

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
		groundTouching +=1 
		doubleJumped = false;
		dashed = false;

	elif(shape_owner.is_in_group("wallSide")):
		wallTouch = true

func hit():
	hp-=1
	hurt.emit(hp)
	print(hp)

@warning_ignore("unused_parameter")
func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner :Node = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if(shape_owner.is_in_group("groundTop")):
		#print(" not grounded")
		groundTouching -=1
	elif(shape_owner.is_in_group("wallSide")):
		wallTouch = false
		facing = int(linear_velocity.x/abs(linear_velocity.x)) if linear_velocity.x != 0 else 0
