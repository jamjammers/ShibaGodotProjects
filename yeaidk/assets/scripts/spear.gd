extends Area2D


@export var speed = 2000.0
@export var stabDuration = 0.05

var state := "off" # "off", "stabbing", "retracting"

func _ready() -> void:
	off()
	$stabTimer.wait_time = stabDuration

func _process(delta: float) -> void:
	if state == "stabbing":
		position.x += speed * delta
	elif state == "retracting":

		position.x -= speed * delta
	pass # Replace with function body.

func stab() -> void:
	show()
	monitorable = true
	$shaftCol.disabled = false
	$pointCol.disabled = false
	$stabTimer.start()
	state = "stabbing";

func retract() -> void:
	$stabTimer.start()
	state = "retracting";
	pass

func off() -> void:
	hide()
	monitorable = false

	state = "off"
	$shaftCol.disabled = true

	$pointCol.disabled = true
	position.x = 0


func _on_stab_timer_timeout() -> void:
	if state == "stabbing":
		retract()
	elif state == "retracting":
		off()
	pass # Replace with function body.
