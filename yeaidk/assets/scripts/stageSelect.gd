extends Control


var list = ["stage1","stage1","stage1","stage1","stage1","stage1","stage1","stage1","stage1"]

var displaying := false

func _ready() -> void:
	randomize()
	$bg.hide()
	pass # Replace with function body.


func display():
	var imgs = randomStages(3)
	var buttons = genButtons(imgs);
	for b in buttons:
		add_child(b)

func genButtons(imgs:Array[String]) -> Array[Button]:
	var buttons: Array[Button] = []
	for i in range(3):
		var b = genButton(imgs[i]);
		b.position = Vector2(i*200-64-200, -64)
		buttons.append(b)

	return buttons

func genButton(imgName) -> Button:
	var button :Button = Button.new();
	button.icon = genPhoto(imgName);
	
	return button
	
func genPhoto(imgName) -> ImageTexture:
	var image: Image = Image.load_from_file("res://assets/images/stagePreview/%s.png"%imgName)
	image.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	var texture = ImageTexture.create_from_image(image)
	
	return texture

func randomStages(n:int) -> Array[String]:
	var out: Array[String] = []
	for i in range(n):
		out.append(list[randi_range(0,list.size()-1)])
	return out

@warning_ignore("unused_parameter")
func _on_player_portal(direction: Portal.portalDirection) -> void:
	if displaying:
		for i in get_children():
			if i is Button:
				i.queue_free()
		displaying = false
		$bg.hide()
	else:
		display()
		displaying = true
		$bg.show()
