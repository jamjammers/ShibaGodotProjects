class_name Portal extends Node2D

enum portalDirection{
	LEFT, UP, RIGHT, DOWN
	
}
static func reverseDir(dir: portalDirection) -> portalDirection:
	return ((dir + 2) % 4) as portalDirection

@export var triggered := false

@export var direction : portalDirection = portalDirection.LEFT;

var linkStage: StageReference = null;


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.enterPortal(self, !triggered, linkStage)
		

func exitOffset() -> Vector2:
	match direction:
		portalDirection.LEFT:
			return Vector2(70, 0)
		portalDirection.RIGHT:
			return Vector2(-70, 0)
		portalDirection.UP:
			return Vector2(0, 70)
		portalDirection.DOWN:
			return Vector2(0, -70)
	return Vector2.ZERO
