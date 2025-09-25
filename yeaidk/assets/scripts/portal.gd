class_name Portal extends Node2D

enum portalDirection{
	LEFT, RIGHT, UP, DOWN
}

@export var triggered := false

var direction : portalDirection = portalDirection.LEFT;



func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Player":
		body.enterPortal(direction)
		print("google")
		triggered = true; #why?
