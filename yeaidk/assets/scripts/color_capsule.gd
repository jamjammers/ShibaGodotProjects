extends Control
@export var color: Color;
@export var radius:float;
@export var height:float;

func _draw():
	draw_circle(Vector2(0,height/2-radius), 
		radius, 
		color,
		true
		)
	draw_circle(Vector2(0,-height/2+radius), 
		radius, 
		color,
		true
		)
	draw_rect(Rect2(-radius,-height/4, radius*2, height/2), 
		color
		)
