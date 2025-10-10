extends Control


var LeftRight: Array[StageReference] = [];
var LeftRightDown: Array[StageReference] = [];
var stages: Dictionary[Array, Array] = {}; # Directions, Array of StageReferences

var displaying := false

func _ready() -> void:
	randomize()
	$RichTextLabel.hide()

	stages[[Portal.portalDirection.LEFT, Portal.portalDirection.RIGHT]] = loadFromDir("res://assets/levels/regular/LeftRight")
	stages[[Portal.portalDirection.LEFT, Portal.portalDirection.RIGHT, Portal.portalDirection.DOWN]] = loadFromDir("res://assets/levels/regular/LeftRightDown")
	stages[[Portal.portalDirection.UP]] = loadFromDir("res://assets/levels/regular/Up")
	pass # Replace with function body.

func display(portalEntered: Portal):
	var chosenStages = randomStages(3, Portal.reverseDir(portalEntered.direction))
	
	var stringBuilder = "select from: "
	for stage in chosenStages[0]:
		stringBuilder += stage.name + " | "
	print(stringBuilder.substr(0, stringBuilder.length() - 3))
	var buttons = genButtons(chosenStages[0], portalEntered, chosenStages[1]);
	$RichTextLabel.show()
	for b in buttons:
		add_child(b)

func stopDisplay(stage: StageReference, portalEntered: Portal):
	$RichTextLabel.hide()
	for child in get_children():
		if child is Button:
			child.queue_free()
	displaying = false
	get_parent().buttonSelect(stage, portalEntered)

func genButtons(buttonStages: Array, portalEntered: Portal, buttonLocs: Array) -> Array[Button]:
	
	var buttons: Array[Button] = []
	for i in range(buttonStages.size()):
		var button: Button = Button.new();
		button.icon = buttonStages[i].getImage()
		button.size = Vector2(128, 128)

		button.pressed.connect(buttonPress.bind(buttonStages[i], portalEntered, buttonLocs[i]))
		button.position = Vector2(i * 200 - 64 - 200, -64)
		buttons.append(button)

	return buttons

func loadFromDir(directory: String) -> Array:
	var dir = DirAccess.open(directory)
	var list = []
	if dir:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if not dir.current_is_dir():
				list.append(StageReference.new(null, directory + "/" + fname))
			fname = dir.get_next()
		dir.list_dir_end()
	return list;

func totalLength(direction) -> int:
	var out := 0
	for key in stages.keys():
		if key.has(Portal.str(direction)):
			out += stages[key].size()
	return out

@warning_ignore("unused_parameter")
func randomStages(n: int, direction: Portal.portalDirection) -> Array:
	var out: Array[Array] = [[], []]

	var locs: Array[Array] = []
	var list: Array[StageReference] = []
	for key in stages.keys():
		if key.has((direction)):
			list.append_array(stages[key])
			for i in range(stages[key].size()):
				locs.append(key)
			
	
	for i in range(min(n, list.size())):
		var randNum = randi_range(0, list.size() - 1)
		out[0].append(list[randNum])
		out[1].append(locs[randNum])
		list.remove_at(randNum)
		locs.remove_at(randNum)
	return out

#stuff for button presses
func buttonPress(stage: StageReference, portalEntered: Portal, buttonLoc: Array):
	stages[buttonLoc].erase(stage)
	stopDisplay(stage, portalEntered)
	pass
