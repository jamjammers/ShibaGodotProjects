extends Enemy
func _ready() -> void:
	super._ready()
	maxTimer = 2.0
	contactDamage = false
	

func attack():
	print("Archer Attack")
	var arrow = preload("res://assets/enemy_stuff/enemy_arrow.tscn").instantiate() as RigidBody2D
	get_parent().add_child(arrow)
	arrow.global_position = global_position
	var direction = (target.global_position - global_position).normalized()
	arrow.linear_velocity = direction * 1200
	
