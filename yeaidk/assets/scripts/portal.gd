class_name Portal extends Node2D

enum portalDirection{
	LEFT, UP, RIGHT, DOWN
	
}
static func reverseDir(dir: portalDirection) -> portalDirection:
	return ((dir + 2) % 4) as portalDirection

static func str(dir: portalDirection) -> String:
	match dir:
		portalDirection.LEFT:
			return "Left"
		portalDirection.RIGHT:
			return "Right"
		portalDirection.UP:
			return "Up"
		portalDirection.DOWN:
			return "Down"
	return "Unknown"

@export var direction : portalDirection = portalDirection.LEFT;


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Player entered portal facing %d"%direction)
		body.enterPortal(self)
		

func exitOffset(rightExit:bool=false) -> Vector2:
	match direction:
		portalDirection.LEFT:
			return Vector2(70, 0)
		portalDirection.RIGHT:
			return Vector2(-70, 0)
		portalDirection.UP:
			return Vector2(0, 70)
		portalDirection.DOWN:
			return Vector2(100 if rightExit else -100, -100)
	return Vector2.ZERO
