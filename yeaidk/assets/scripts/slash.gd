extends Area2D


var state := "off" # "off", "slashing"

func _ready() -> void:
	$col.disabled = true
	var slashDuration = $slashSprite.sprite_frames.get_frame_count("slash") / $slashSprite.sprite_frames.get_animation_speed("slash")  
	$slashTimer.wait_time = slashDuration
	$cooldown.wait_time = slashDuration * 1.5
	hide()

func _draw() -> void:
	var points = $col.polygon
	for i in range(points.size()):
		var start_point = points[i]
		var end_point = points[(i + 1) % points.size()] # Wrap around to the first point
		
		draw_line(start_point, end_point, Color.RED if $col.disabled else Color.GREEN, 2)

func activate(dir)-> bool:
	if $cooldown.is_stopped() == false or state != "off":
		return false
	scale.x = 1 if dir.x > 0 else -1
	print(dir)
	if abs(dir.x) < abs(dir.y):
		if scale.x * dir.y > 0:
			rotation_degrees = 90
		else:
			rotation_degrees = -90
	else:
		rotation_degrees = 0

	state = "slashing"
	show()
	$col.disabled = false
	$slashTimer.start()
	$slashSprite.play("slash", true)
	queue_redraw()
	return true



func _timer_end():
	state = "off"
	hide()
	$col.disabled = true
	$slashSprite.stop()
	$slashSprite.frame = 0
	queue_redraw()
	$cooldown.start()
