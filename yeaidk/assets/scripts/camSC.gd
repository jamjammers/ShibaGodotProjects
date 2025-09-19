extends Camera2D

@export var target: RigidBody2D;

var r = 0.5
var mult = 100
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var targetPos := target.position
	
	var val = 1-pow(r,delta*mult)
	
	position.x = val*targetPos.x+(1-val)*position.x

	position.y = val*targetPos.y+(1-val)*position.y
