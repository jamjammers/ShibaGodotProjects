class_name Item extends Area2D

@export var type: ItemType
@export var ability: String 


enum ItemType{
	ABILITY, WEAPON, CONSUMABLE
}

var count :float= 0

var touched = false
func _draw() -> void:
	draw_rect($CollisionShape2D.shape.get_rect(), Color.GREEN if touched else Color.RED , false)
func _process(delta: float) -> void:
	count += delta

	if($ColorRect):
		if(count >= PI * 2):
			count -= PI * 2
		var CRscale = $ColorRect.scale
		CRscale.x = 0.5 - sin(count * 3)/2
		$ColorRect.scale = CRscale
	
		$ColorRect.position.y = -20 - 20 * sin(count * 5)

		queue_redraw()
