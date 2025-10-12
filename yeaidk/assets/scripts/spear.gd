extends Area2D


@export var speed = 2000.0
@export var stabDuration = 0.05

var state := "off" # "off", "stabbing", "retracting"

func _ready() -> void:
	off()
	$stabTimer.wait_time = stabDuration

func _process(delta: float) -> void:
	if state == "stabbing":
		position.x += speed * delta * cos(rotation)
		position.y += speed * delta * sin(rotation)
	elif state == "retracting":

		position.x -= speed * delta * cos(rotation)
		position.y -= speed * delta * sin(rotation)
	pass # Replace with function body.

@warning_ignore("unused_parameter")
func activate(dir) -> bool:
	if state != "off" or !$cooldown.is_stopped():
		return false
	rotation = dir.angle()

	show()
	monitorable = true
	$col.disabled = false
	$stabTimer.start()
	state = "stabbing";
	return true

func retract() -> void:
	$stabTimer.start()
	state = "retracting";

func off() -> void:
	hide()
	monitorable = false

	state = "off"
	$col.disabled = true

	position.x = 0
	position.y = 0

	$cooldown.start()


func _on_stab_timer_timeout() -> void:
	if state == "stabbing":
		retract()
	elif state == "retracting":
		off()
	pass # Replace with function body.
