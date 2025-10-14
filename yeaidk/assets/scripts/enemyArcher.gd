extends BaseEnemy

var gravity

func _ready() -> void:
	super._ready()
	maxTimer = 2.0
	contactDamage = false
	gravity = ProjectSettings.get("physics/2d/default_gravity")/30
	

func attack():
	var arrow = preload("res://assets/enemy_stuff/enemy_arrow.tscn").instantiate() as EnemyArrow
	get_parent().add_child(arrow)
	arrow.global_position = global_position
	var relative_pos = target.global_position - global_position

	var m = arrow.speed #magnitude of the arrow
	var g = gravity * arrow.gravity_scale #gravity
	var x = relative_pos.x
	var y = -relative_pos.y
	var angle = -atan((pow(m,2)-sqrt(pow(m,4)-2*pow(g,2)*pow(m,2)*y-pow(g,4)*pow(x,2)))/(pow(g,2)*x))
	if(x < 0):
		angle += PI
	print("Angle: ", rad_to_deg(angle))
	print("Player Angle: ", rad_to_deg(relative_pos.angle()))
	var vector = Vector2(cos(angle), sin(angle))
	arrow.launch(vector)
	
