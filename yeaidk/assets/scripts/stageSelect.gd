extends Control


var list: Array[StageReference] = [];



var displaying := false

func _ready() -> void:
	randomize()
	list.append(StageReference.new(null,"res://assets/levels/stage1.tscn"))
	list.append(StageReference.new(null,"res://assets/levels/stage1.tscn"))
	list.append(StageReference.new(null,"res://assets/levels/stage1.tscn"))
	list.append(StageReference.new(null,"res://assets/levels/stage1.tscn"))
	list.append(StageReference.new(null,"res://assets/levels/stage1.tscn"))
	pass # Replace with function body.

func display(portal: Portal):
	var stages = randomStages(3, portal)
	var buttons = genButtons(stages, portal);
	for b in buttons:
		add_child(b)

func stopDisplay(stage:StageReference, portal: Portal):
	for child in get_children():
		if child is Button:
			child.queue_free()
	displaying = false
	get_parent().buttonSelect(stage, portal)

func genButtons(stages: Array[StageReference], portal: Portal) -> Array[Button]:
	var buttons: Array[Button] = []
	for i in range(3):
		var b = genButton(stages[i], portal);
		b.position = Vector2(i * 200 - 64 - 200, -64)
		buttons.append(b)

	return buttons

func genButton(stage:StageReference, portal: Portal) -> Button:
	var button: Button = Button.new();
	button.icon = stage.getImage()
	button.pressed.connect(buttonPress.bind(stage, portal))
	return button

@warning_ignore("unused_parameter")
func randomStages(n: int, portal: Portal) -> Array[StageReference]:
	var out: Array[StageReference] = []
	for i in range(n):
		out.append(list[randi_range(0, list.size() - 1)])
	return out

#stuff for button presses
func buttonPress(stage:StageReference, portal: Portal):
	stopDisplay(stage, portal)
	pass
