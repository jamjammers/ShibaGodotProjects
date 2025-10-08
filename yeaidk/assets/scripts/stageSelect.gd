extends Control


var list: Array[StageReference] = [];



var displaying := false

func _ready() -> void:
	randomize()
	
	var dir = DirAccess.open("res://assets/levels")
	if dir:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if not dir.current_is_dir():
				list.append(StageReference.new(null, "res://assets/levels/%s" % fname))
			fname = dir.get_next()
		dir.list_dir_end()

func display(portalEntered: Portal):
	var stages = randomStages(3, portalEntered)
	var buttons = genButtons(stages, portalEntered);
	for b in buttons:
		add_child(b)

func stopDisplay(stage:StageReference, portalEntered: Portal):
	for child in get_children():
		if child is Button:
			child.queue_free()
	displaying = false
	get_parent().buttonSelect(stage, portalEntered)

func genButtons(stages: Array[StageReference], portalEntered: Portal) -> Array[Button]:
	var buttons: Array[Button] = []
	for i in range(3):
		var b = genButton(stages[i], portalEntered);
		b.position = Vector2(i * 200 - 64 - 200, -64)
		buttons.append(b)

	return buttons

func genButton(stage:StageReference, portalEntered: Portal) -> Button:
	var button: Button = Button.new();
	button.icon = stage.getImage()
	button.size = Vector2(128, 128)

	button.pressed.connect(buttonPress.bind(stage, portalEntered))
	return button

@warning_ignore("unused_parameter")
func randomStages(n: int, portal: Portal) -> Array[StageReference]:
	var out: Array[StageReference] = []
	for i in range(n):
		out.append(list[randi_range(0, list.size() - 1)])
	return out

#stuff for button presses
func buttonPress(stage:StageReference, portalEntered: Portal):
	list.erase(stage)
	stopDisplay(stage, portalEntered)
	pass
