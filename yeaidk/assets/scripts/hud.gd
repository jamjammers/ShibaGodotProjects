extends CanvasLayer

var gears: Array[TextureRect] = []

func _ready() -> void:
	gears.append_array($hp.get_children());

func _on_player_hurt(hp: int) -> void:
	for i in range(0,min(hp, len(gears))):
		gears[i].show()
	for i in range(max(hp,0), len(gears)):
		gears[i].hide()
		
