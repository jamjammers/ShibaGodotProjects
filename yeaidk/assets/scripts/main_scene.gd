extends Node


var player: RigidBody2D = null
var sceneCache :Dictionary[String, PackedScene] = {}

var screenFreezeState := false

var shaderBlurState := false

func _ready() -> void:
	blur(false)
	sceneCache["startStage"] = load("res://assets/levels/startStage.tscn")
	player = $frameVP/Player
	pass # Replace with function body.

func loadScene(stage: StageReference):
	if !sceneCache.has(stage.name):
		var scene = stage.loadStage()
		if scene:
			sceneCache[stage.name] = scene
		else:
			print("Error: Failed to load scene %s"%stage.name)

func _on_player_portal(portal:Portal, new: bool, stage:StageReference) -> void:
	if new:
		$stageSelect.display(portal)
		blur(true)
		freezeScene()
	else:
		print("stage name:"+stage.name)
		changeStage(stage, portal)
		pass

func freezeScene(freezeState = true) -> void:

	screenFreezeState = freezeState

	$frameVP/Player.call_deferred("enterFreeze", freezeState)
	#search for stages
	for child in $frameVP.get_children():
		if !(child.is_in_group("stage")):
			continue
		#search for things that can be frozen I guess
		for node in child.get_children():
			if not (node is RigidBody2D):
				continue
			if !node.has_method("enterFreeze"):
				continue
			node.call_deferred("enterFreeze", (freezeState))

func blur(value = "") -> void:
	if value is String and value == "":
		var shader_material = $frame.material as ShaderMaterial

		shaderBlurState = not shaderBlurState
		(shader_material).set_shader_parameter("go", shaderBlurState)
	elif (value is bool):
		var shader_material = $frame.material as ShaderMaterial

		shaderBlurState = value
		(shader_material).set_shader_parameter("go", shaderBlurState)

func buttonSelect(stage:StageReference, portal: Portal) -> void:
	freezeScene(false)
	portal.triggered = true
	portal.linkStage = stage
	print(portal.get_parent().name)
	blur(false)
	loadScene(stage)
	changeStage(stage, portal)

func changeStage(stage:StageReference, portal: Portal) -> void:
	var oldStage: StageReference;
	for child in $frameVP.get_children():
		if child.is_in_group("stage"):
			oldStage = StageReference.new(child, "")
			
			child.queue_free()
	call_deferred("loadSceneInstance", stage, portal.direction, oldStage)
	
func loadSceneInstance(stage:StageReference, direction: Portal.portalDirection, oldStage: StageReference) -> void:
	var packed_scene = sceneCache[stage.name]
	if not packed_scene or not packed_scene is PackedScene:
		print("Error: Scene for %s is not loaded properly." % stage.name)
		return
	var instance = packed_scene.instantiate()
	if not instance or not instance is Node2D:
		print("Error: Failed to instantiate scene for %s." % stage.name)
		return
	$frameVP.add_child(instance)
	portalUpdate(oldStage, direction, instance)

func portalUpdate(oldStage: StageReference, direction: Portal.portalDirection, instance) -> void:
	player.linear_velocity = Vector2.ZERO
	
	var exitPortal: Portal;

	for portalCandiate in instance.get_children():
		if not portalCandiate is Portal:
			continue
		if not portalCandiate.direction == Portal.reverseDir(direction):
			continue
		exitPortal = portalCandiate
		break

	if not exitPortal:
		print("Error: No exit portal found in the new stage.")
		return
		
	exitPortal.triggered = true
	exitPortal.linkStage = oldStage
	
	player.position = exitPortal.position + exitPortal.exitOffset()
	# remove outers...
