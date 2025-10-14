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

@export var hp := 3

var test = false


func _ready() -> void:
	# print("Debug: %s enemy is ready"%name)
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
		var colSize:Vector2 = ($physicalCol.shape as RectangleShape2D).size
		var offset = Vector2(colSize.x/2-1, colSize.y/2-1)
		draw_line(offset, target.global_position - global_position, Color.GREEN if raycast(offset) else Color.RED, 2)
		draw_line(-offset, target.global_position - global_position, Color.GREEN if raycast(-offset) else Color.RED, 2)
		draw_line(Vector2(offset.x, -offset.y), target.global_position - global_position, Color.GREEN if raycast(Vector2(offset.x, -offset.y)) else Color.RED, 2)
		draw_line(Vector2(-offset.x, -offset.y), target.global_position - global_position, Color.GREEN if raycast(Vector2(-offset.x, -offset.y)) else Color.RED, 2)

func attackProcess():
	active = false
	if target == null:
		return
	# check Line of sight
	var colSize:Vector2 = ($physicalCol.shape as RectangleShape2D).size
	
	if not(
		raycast(Vector2(colSize.x/2-1, colSize.y/2-1)) or 
		raycast(Vector2(-colSize.x/2+1, colSize.y/2-1)) or 
		raycast(Vector2(colSize.x/2-1, -colSize.y/2+1)) or 
		raycast(Vector2(-colSize.x/2+1, -colSize.y/2+1))
	):
		return
	active = true

	if (timer > 0):
		return
	attack()
	timer = maxTimer

func raycast(offset: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position+offset, target.global_position)
	
	var layers = 1+2+pow(2,5)

	query.collision_mask = layers

	var result = space_state.intersect_ray(query)

	if !(result):
		return false
	if (!result.is_empty() and result.collider.name != target.name):
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
		linear_velocity = Vector2.ZERO
		pass
	pass # Replace with function body.

func _on_contact_area_entered(area: Area2D) -> void:
	if (area.collision_layer & 32 != 0):
		if area.name == "spear":
			var colSize:Vector2 = ($physicalCol.shape as RectangleShape2D).size
			if not(
				raycast(Vector2(colSize.x/2-1, colSize.y/2-1)) or 
				raycast(Vector2(-colSize.x/2+1, colSize.y/2-1)) or 
				raycast(Vector2(colSize.x/2-1, -colSize.y/2+1)) or 
				raycast(Vector2(-colSize.x/2+1, -colSize.y/2+1))
			):
				return
		var yDir = 1;
		if area.name == "clawSlash" and area.direction == Global.Dir.UP:
			yDir = -1
		elif area.name == "clawSlash" and area.direction == Global.Dir.DOWN:
			yDir = 1
			

		hp -=1
		timer = min(timer +0.25, 1.5)
		var dir = -1 if area.global_position > global_position else 1
		sleeping = true
		sleeping = false
		linear_velocity=(Vector2(dir * 500, -500* yDir)*(area.knockback if area.has_meta("knockback") else 1))

		
		var parent = area.get_parent() as RigidBody2D
		parent.linear_velocity.y /= 3
		parent.apply_central_impulse(Vector2(0, -1000))
		emitParticles()
		print("Enemy hit, %s hp remains"%hp+ str(get_child_count()))
		if (hp <= 0):
			queue_free()
	
	
func emitParticles():
	var emitter = GPUParticles2D.new()
	emitter.texture = PlaceholderTexture2D.new()
	emitter.lifetime = 1.0
	emitter.one_shot = true
	emitter.amount = 30
	emitter.emitting = true
	emitter.explosiveness = 1.0
	emitter.process_material = load("res://assets/textures/dedparticleeffect.tres")
	add_child(emitter)
	var emitterKillTimer = Timer.new()
	emitterKillTimer.one_shot = true
	emitterKillTimer.wait_time = 1.0
	add_child(emitterKillTimer)
	emitterKillTimer.start()
	emitterKillTimer.timeout.connect(func() -> void:
		emitter.queue_free()
		emitterKillTimer.queue_free()
		)
	# emitter.restart()
