extends BaseEnemy
func _ready() -> void:
	super._ready()
	maxTimer = 2.0
	contactDamage = false
	gravity_scale = 0
	

func attack():
	var arrow = preload("res://assets/enemy_stuff/enemy_arrow.tscn").instantiate() as EnemyArrow
	get_parent().add_child(arrow)
	arrow.global_position = global_position
	var relative_pos = target.global_position - global_position

	var m = arrow.speed #magnitude of the arrow
	var g = ProjectSettings.get("physics/2d/default_gravity")*arrow.gravity_scale/30
	#a=\ \tan^{-1}\left(\frac{-2m^{2}+\sqrt{4m^{4}-4\left(2m^{2}w+v^{2}\right)}}{-2v}\right)
	var v = relative_pos.x
	var w = -relative_pos.y
	var angle = -atan((pow(m,2)-sqrt(pow(m,4)-2*pow(g,2)*pow(m,2)*w-pow(g,4)*pow(v,2)))/(pow(g,2)*v))
	if(v < 0):
		angle += PI
	print("Angle: ", rad_to_deg(angle))
	print("Player Angle: ", rad_to_deg(relative_pos.angle()))
	var vector = Vector2(cos(angle), sin(angle))
	arrow.launch(vector)
	
