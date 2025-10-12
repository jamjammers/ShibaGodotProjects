extends "res://assets/scripts/enemy.gd"

func _ready() -> void:
    maxTimer = 2.0
    contactDamage = false

func attack():
    print("Archer Attack")
    var arrow = preload("res://assets/assetScenes/enemy_arrow.tscn").instantiate() as RigidBody2D
    get_parent().add_child(arrow)
    arrow.global_position = global_position
    arrow.direction = (target.global_position - global_position).normalized()
    arrow.linear_velocity = arrow.direction * 1200
    

