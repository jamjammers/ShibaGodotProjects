extends RigidBody2D

signal hurt(hp: int)
signal portal(direction: Portal.portalDirection, new)

@export var speed = 600.0
@export var acceleration = 6000.0
@export var friction = 6000.0

var frozen := false

var groundTouching := 0
var jumping := 0
var wallTouch := false
var wallAsim := false

var hp := 5

var stored_velocity: Vector2 = Vector2.ZERO

var abilities := {"dash": true, "double_jump": true, "wall_attach": true};
var dashed := false # can only dash once per groundTouching state
var doubleJumped := false # can only double once per groundTouching
var facing: int;

var test = false;

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		test = true
		gravity_scale = 0
		print("Debug: "+str(position))
		linear_velocity = Vector2.ZERO
		return
	

	wallAttachCheck()

	if (wallAsim):
		wallJump()
	else:
		jump()
		
		dash()

func _physics_process(delta):
	if test:
		testModeMovement()
		return
	jumpCont()
	if (wallAsim):
		pass
	else:
		horizMovement(delta)

# movement checks and executions
func testModeMovement():
	if Input.is_action_pressed("moveLeft"):
		position.x -= 100
	if Input.is_action_pressed("moveRight"):
		position.x += 100
	if Input.is_action_pressed("moveUp"):
		position.y -= 100
	if Input.is_action_pressed("moveDown"):
		position.y += 100
func wallAttachCheck():
	if !Input.is_action_just_pressed("wallAttach"):
		return
	if !wallTouch:
		return
	if !abilities.wall_attach:
		return
	wallAsim = !wallAsim
	linear_velocity.y = 0
	gravity_scale = 0 if wallAsim else 3
func jump():
	if (!Input.is_action_just_pressed("jump")):
		return

	if (groundTouching):
		apply_central_impulse(Vector2(0, -1000))
		jumping = -500
	elif (!doubleJumped):
		linear_velocity.y = -100
		apply_central_impulse(Vector2(0, -1000))

		doubleJumped = true;
func wallJump():
	if !Input.is_action_just_pressed("jump"):
		return
	var inputDir = Input.get_axis("moveLeft", "moveRight")
	linear_velocity.y = 0
	var mult = inputDir if inputDir == facing else 0.0
	apply_central_impulse(Vector2(mult * 800, -1000))
	doubleJumped = false;
	jumping = -500
	wallAsim = false
	gravity_scale = 0 if wallAsim else 3
func dash():
	if (!abilities.dash or dashed):
		return
	if !$dashTimer.is_stopped():
		return
	if !Input.is_action_just_pressed("dash"):
		return
	if !groundTouching:
		dashed = true
	linear_velocity.y = -200;
	
	apply_central_impulse(Vector2(1700 * facing, 0))
	$dashTimer.start();
func jumpCont():
	if !Input.is_action_pressed("jump") or linear_velocity.y > 0 or wallAsim:
		jumping = 0
	elif (jumping):
		apply_central_force(Vector2(0, jumping))
func horizMovement(delta):
	var input_dir = Input.get_axis("moveLeft", "moveRight")
	if input_dir != 0:
		# Accelerate toward target speed
		facing = int(input_dir / abs(input_dir));
		linear_velocity.x = move_toward(linear_velocity.x, input_dir * speed, acceleration * delta)
	else:
		# Friction when no input
		linear_velocity.x = move_toward(linear_velocity.x, 0, friction * delta)

func enterFreeze(freezeState = true) -> void:
	freeze = freezeState
	sleeping = freezeState

	if freezeState:
		stored_velocity = linear_velocity
		linear_velocity = Vector2.ZERO
		gravity_scale = 0
	else:
		stored_velocity = Vector2.ZERO
		linear_velocity = stored_velocity
		gravity_scale = 3

	# linear_velocity = Vector2.ZERO
	# gravity_scale = 0

@warning_ignore("unused_parameter")
func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner: Node = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	
	if (shape_owner.is_in_group("groundTop")):
		groundTouching += 1
		doubleJumped = false;
		dashed = false;

	elif (shape_owner.is_in_group("wallSide")):
		wallTouch = true

#trigger when hit by enemy
func hit():
	hp -= 1
	hurt.emit(hp)
	print("Incomplete: got hurt. "+str(hp)+" hp remains");

#trigger when hit portal
func enterPortal(portalEntered: Portal, new: bool, stage: StageReference) -> void:
	portal.emit(portalEntered, new, stage)

@warning_ignore("unused_parameter")
func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner: Node = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if (shape_owner.is_in_group("groundTop")):
		groundTouching -= 1
	elif (shape_owner.is_in_group("wallSide")):
		wallTouch = false
		facing = int(linear_velocity.x / abs(linear_velocity.x)) if linear_velocity.x != 0 else 0
