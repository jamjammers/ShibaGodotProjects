class_name StageReference

var stagePath : String

var name : String

var portals: Array[Portal.portalDirection] = []


func _init(stage: Node2D = null, path: String = "") -> void:
	#generally should only be done at runtime
	if stage != null:
		stagePath = stage.get_path()
		name = stage.name
		for stageChild in stage.get_children():
			if stageChild is Portal:
				portals.append(stageChild.direction)
	elif path != "":
		stagePath = path
		name = path.get_file().get_basename()
	else:
		push_error("StageReference must be initialized with either a Node2D or a stage path.")


func loadStage():
	return ResourceLoader.load(stagePath) 

func getImage() -> ImageTexture:
	if FileAccess.file_exists("res://assets/images/stagePreview/%s.png" % name) == false:
		
		# print("Warning: No preview image found for stage %s"%name)
		return null
	var texture: Texture2D = load("res://assets/images/stagePreview/%s.png" % name)
	if !texture:
		print("Error: Failed to load image for stage %s"%name)
		return null
	var image: Image = texture.get_image()

	image.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	var outTexture = ImageTexture.create_from_image(image)
	return outTexture
