extends CanvasLayer

var gears: Array[TextureRect] = []

func _ready() -> void:
	gears.append_array($hp.get_children());

func _on_player_hurt(hp: int) -> void:
	for i in range(0,hp):
		gears[i].show()
	for i in range(hp, len(gears)):
		gears[i].hide()
		
