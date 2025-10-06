extends Node

var sceneData : Dictionary

var savePath := "user://globals.save"

func _ready() -> void:
	if FileAccess.file_exists("user://globals.save"):
		_loadData()
		print("Note: data loaded from save file: %s"%sceneData)
	else:
		sceneData = {}
		_saveData()
		print("Note: data loaded from no save file.")
	sceneData = {}
	_saveData()


func _loadData() -> void:
	var file = FileAccess.open(savePath, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		file.close()

		sceneData = (JSON.parse_string(data) as Dictionary[String, Dictionary])
		
	else:
		sceneData = {}
		_saveData()

func _saveData() -> void:
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	if file:
		var data = JSON.stringify(sceneData)
		file.store_string(data)
		file.close()

func setSceneData(sceneName: String, data: Dictionary) -> void:
	sceneData[sceneName] = data

func getSceneData(sceneName: String) -> Dictionary:
	return sceneData.get(sceneName)

func setPortal(currentScene: String, portalDir: Portal.portalDirection, linkStage: StageReference) -> void:
	if not sceneData.has(currentScene):
		sceneData[currentScene] = {}
	sceneData[currentScene]["portal"+str(portalDir)] = linkStage
	print("\n"+str(Global.sceneData)+"\n")

func getPortal(sceneName: String, direction: Portal.portalDirection) -> StageReference:
	if sceneData.has(sceneName) and sceneData[sceneName].has("portal"+str(direction)):
		return sceneData[sceneName]["portal"+str(direction)]
	print("Warning: No portal data found for scene %s direction %d"%[sceneName, direction])
	return null
