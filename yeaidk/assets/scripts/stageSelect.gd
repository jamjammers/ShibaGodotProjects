extends Control

var list = ["stage1","stage1","stage1","stage1","stage1","stage1","stage1","stage1","stage1"]
func display():
	var imgs = randomStages(3)
	var buttons = genButtons(imgs);
	for b in buttons:
		add_child(b)

func genButtons(imgs:Array[String]) -> Array[Button]:
	var buttons: Array[Button] = []
	for i in range(3):
		var b = genButton(imgs[i]);
		b.position = Vector2(400 + i*450, 350)
		buttons.append(genButton(imgs[i]))

	return buttons

func genButton(imgName) -> Button:
	var button :Button = Button.new();
	button.icon = genPhoto(imgName);
	return button
	
func genPhoto (imgName) -> ImageTexture:
	var image = Image.load_from_file("res://assets/images/stagePreview/%s.png"%imgName)
	var texture = ImageTexture.create_from_image(image)
	
	return texture

func randomStages(n:int) -> Array[String]:
	var out = []
	for i in range(n):
		out.append(list.pop_at(randi_range(0,list.size()-1)))
	return out
