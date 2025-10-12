extends Area2D


var state := "off" # "off", "slashing"

func _ready() -> void:
	$col.disabled = true
	hide()

func _draw() -> void:
	var points = $col.polygon
	for i in range(points.size()):
		var start_point = points[i]
		var end_point = points[(i + 1) % points.size()] # Wrap around to the first point
		
		draw_line(start_point, end_point, Color.RED if $col.disabled else Color.GREEN, 2)

func slash():
	state = "slashing"
	show()
	$col.disabled = false
	$slashTimer.start()
	$slashSprite.play("slash", true)
	queue_redraw()



func _timer_end():
	state = "off"
	hide()
	$col.disabled = true
	$slashSprite.stop()
	$slashSprite.frame = 0
	queue_redraw()
