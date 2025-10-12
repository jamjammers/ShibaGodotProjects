extends RigidBody2D

#### TODO: fix the weirdness of the portal system, add attack dir -> facing

## Triggers when the player gets hurt (broadcasts total hp remaining)
## currently it is connected to the UI to update the health display
signal hurt(hp: int)

## Triggers when the player enters a portal (broadcasts the direction and if it's a new stage)
## currently connected to main_scene to handle stage changing
signal portal(direction: Portal.portalDirection, new)

## controls the player left right speed, acceleration, deceleration
## also controls vertical speed for wall climbing (x2)
@export var speed = 600.0
@export var acceleration = 6000.0
@export var friction = 6000.0

## strength of the jump continuation (TODO: tune)
var jumping := 0

## places that the body touches the ground
var groundContacts := []

## if the player is touching a wall/can attach to a wall/is attached to a wall
var wallTouch := false
var wallTouchDir: Global.Dir
var wallAsimable := false
var wallAsim := false

## hp (what did you expect)
var hp := 5
var invincibility := 0.0;

## when the player is frozen, store the velocity for after freeze
var stored_velocity: Vector2 = Vector2.ZERO

var abilities := {"dash": false, "double_jump": false, "wall_attach": false};
var dashed := false # can only dash once per groundTouching state
var doubleJumped := false # can only double once per groundTouching
var facing: int;

var itemsTouching := []

var test = false;

func _ready() -> void:
	gravity_scale = 3
	facing = 1
	$dashTimer.wait_time = 0.5
	get_viewport().handle_input_locally = true
	pass # Replace with function body.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		test = !test
		if test:
			gravity_scale = 0
			linear_velocity = Vector2.ZERO
		else:
			gravity_scale = 3
	if test:
		return
	if freeze:
		return
	if invincibility > 0.0:
		invincibility = max(invincibility - delta, 0.0)
		if invincibility == 0.0:
			$render.modulate = Color(1, 1, 1, 1)
		else:
			$render.modulate = Color(1, 1, 1, 0.5 + 0.5 * sin(invincibility * 20))
	wallAttachCheck()
	itemPickup()

	if (wallTouch and not groundContacts.size()) or wallAsim:
		wallJump()
	if (wallAsim):
		wallAsimMovement()
		pass
	else:
		jump()
		attack()
		dash()

func _physics_process(delta):
	if test:
		testModeMovement(delta)
		return
	if freeze:
		return
	if (wallAsim):
		pass
	else:
		horizMovement(delta)
		jumpCont()

# movement checks and executions
func testModeMovement(delta):
	if Input.is_action_pressed("moveLeft"):
		position.x -= 500 * delta
	if Input.is_action_pressed("moveRight"):
		position.x += 500 * delta
	if Input.is_action_pressed("moveUp"):
		position.y -= 500 * delta
	if Input.is_action_pressed("moveDown"):
		position.y += 500 * delta
func wallAttachCheck():
	if !wallAsimable:
		return
	if !Input.is_action_just_pressed("wallAttach"):
		return
	
	if !abilities.wall_attach:
		return
	wallAsim = !wallAsim
	if wallAsim:
		facing = -1 if wallTouchDir == Global.Dir.RIGHT else 1
		$render.scale.x = facing

	linear_velocity.y = 0
	gravity_scale = 0 if wallAsim else 3
func itemPickup():
	if itemsTouching.size() == 0:
		return
	if !Input.is_action_just_pressed("itemPickup"):
		return

	for area in itemsTouching:
		area.queue_free()
		if area.type == Item.ItemType.ABILITY:
			abilities[area.ability] = true
	itemsTouching.clear()
func jump():
	if (!Input.is_action_just_pressed("jump")):
		return
	if (groundContacts.size() > 0):
		apply_central_impulse(Vector2(0, -1000))
		jumping = -500
	elif (!doubleJumped and abilities.double_jump):
		linear_velocity.y = -100
		apply_central_impulse(Vector2(0, -1000))

		doubleJumped = true;
func wallJump():
	if !Input.is_action_just_pressed("jump"):
		return
	if !abilities.wall_attach:
		return
	linear_velocity.y = -1000
	var mult = 1 if wallTouchDir == Global.Dir.LEFT else -1
	linear_velocity.x = 700 * mult
	doubleJumped = false;
	jumping = -0
	wallAsim = false
	gravity_scale = 3
func dash():
	if (!abilities.dash or dashed):
		return
	if !$dashTimer.is_stopped():
		return
	if !Input.is_action_just_pressed("dash"):
		return
	if groundContacts.size() == 0:
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
		if $clawSlash.state == "off":
			facing = int(input_dir / abs(input_dir));
		$render.scale.x = facing

		
		linear_velocity.x = move_toward(linear_velocity.x, input_dir * speed, acceleration * delta)
	else:
		# Friction when no input
		linear_velocity.x = move_toward(linear_velocity.x, 0, friction * delta)
func wallAsimMovement():
	if !wallAsim:
		return
	var verticalAxis = Input.get_axis("moveUp", "moveDown")
	linear_velocity.y = verticalAxis * speed * 2
	
func attack():
	if Input.is_action_just_pressed("attack") == false:
		return
	if !($spear/stabTimer.is_stopped()):
		return
	var mouse_pos = get_global_mouse_position()

	var dir = (mouse_pos - global_position).normalized()
	facing = 1 if dir.x > 0 else -1
	$render.scale.x = facing
	$clawSlash.slash()
	$clawSlash.scale.x = 1 if dir.x > 0 else -1

	# $spear.rotation = dir.angle()
	# $spear.stab()
	pass

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

func hit(fromRight: bool) -> void:
	if invincibility > 0.0:
		return
	if fromRight:
		linear_velocity = (Vector2(1200, -750))
	else:
		linear_velocity = Vector2(-1200, -750)
	hp -= 1
	hurt.emit(hp)
	invincibility = 1.0;
	print("Incomplete: got hurt. " + str(hp) + " hp remains");

func enterPortal(portalEntered: Portal) -> void:
	portal.emit(portalEntered)


@warning_ignore("unused_parameter")
func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner: CollisionShape2D = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if (shape_owner.is_in_group("groundTop")):
		if not groundContacts.has(shape_owner):
			groundContacts.append(shape_owner)
		doubleJumped = false;
		dashed = false;

	elif (shape_owner.is_in_group("wallSide")):
		wallTouch = true
		wallTouchDir = Global.genDir(global_position.x, body.global_position.x)
		var shape = shape_owner.shape
		var y = 0
		var x = 0
		var gtf = shape_owner.get_global_transform()
		if shape is RectangleShape2D:
			var ext = shape.extents
			y = ext.y * 2 * gtf.y.length()
			x = ext.x * 2 * gtf.x.length()
		if y > 75 or x > 75:
			wallAsimable = true
		else:
			wallAsimable = false

@warning_ignore("unused_parameter")
func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner: Node = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if (shape_owner.is_in_group("groundTop")):
		groundContacts.erase(shape_owner)

	elif (shape_owner.is_in_group("wallSide")):
		wallTouch = false
		wallAsimable = false
		if wallAsim:
			wallAsim = false
			linear_velocity.y = 0
			gravity_scale = 3

			apply_central_force(Vector2(700 * -facing, -300) * 60)
			facing = -facing
			$render.scale.x = facing


func callAfterDelay(function: Callable, delay: float, args: Array = []) -> void:
	var timer = Timer.new();
	timer.one_shot = true
	timer.wait_time = delay
	add_child(timer)
	timer.start()
	timer.timeout.connect(func() -> void:
		function.callv(args)
		timer.queue_free()
		)

func _on_trigger_col_area_entered(area: Area2D) -> void:
	if area.is_in_group("item"):
		itemsTouching.append(area)
		# inventory add item here
		if area.type == Item.ItemType.ABILITY:
			abilities[area.ability] = true
	pass # Replace with function body.

func _on_trigger_col_area_exited(area: Area2D) -> void:
	if area.is_in_group("item"):
		itemsTouching.erase(area)
	pass # Replace with function body.
