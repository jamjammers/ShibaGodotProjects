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
	var direction = (target.global_position - global_position).normalized()
	arrow.launch(direction)
	
