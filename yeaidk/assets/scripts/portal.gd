extends Node2D

signal triggerArea(new, direction)

@export var triggered := false

@export var direction : portalDirection = portalDirection.LEFT;

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		triggerArea.emit(triggered, direction)
		triggered = true;
	pass # Replace with function body.

enum portalDirection{
	LEFT, RIGHT, UP, DOWN
}
