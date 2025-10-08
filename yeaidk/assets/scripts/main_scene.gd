extends Node


var player: RigidBody2D = null
var sceneCache: Dictionary[String, PackedScene] = {}

var screenFreezeState := false

var shaderBlurState := false

var currentStage: StageReference = StageReference.new(null, "res://assets/levels/reservedStages/startStage.tscn")

func _ready() -> void:
	# blur(false)
	sceneCache["startStage"] = load("res://assets/levels/reservedStages/startStage.tscn")
	player = $VPContainer/frameVP/Player
	$VPContainer/frameVP.handle_input_locally = true  
	pass # Replace with function body.

func _on_player_portal(portalEntered: Portal) -> void:
	print("goober")
	var new = Global.getPortal(currentStage.name, portalEntered.direction) == null
	if new:
		$stageSelect.display(portalEntered)
		blur(true)
		freezeScene()
	else:
		var targetStage = Global.getPortal(currentStage.name, portalEntered.direction)
		player.collision_layer = 16

		changeStage(targetStage, portalEntered)
		pass

func _input(event):
	if event is InputEventMouseButton:		
		# Convert to SubViewport coordinates
		var local_pos = $VPContainer.get_local_mouse_position()
		
		# Send to SubViewport manually
		var new_event = event.duplicate()
		new_event.position = local_pos
		$VPContainer/frameVP.push_input(new_event)


func loadScene(stage: StageReference):
	if !sceneCache.has(stage.name):
		var scene = stage.loadStage()
		if scene:
			sceneCache[stage.name] = scene
		else:
			print("Error: Failed to load scene %s"%stage.name)

func freezeScene(freezeState = true) -> void:
	screenFreezeState = freezeState

	$VPContainer/frameVP/Player.call_deferred("enterFreeze", freezeState)
	#search for stages
	for child in $VPContainer/frameVP.get_children():
		if !(child.is_in_group("stage")):
			continue
		#search for things that can be frozen I guess
		for node in child.get_children():
			if not (node is RigidBody2D):
				continue
			if !node.has_method("enterFreeze"):
				continue
			node.call_deferred("enterFreeze", (freezeState))

func blur(value = null) -> void:
	var shader_material = $VPContainer/frameVP/blurShader2.material as ShaderMaterial
	var shader_material2 = $blurShader.material as ShaderMaterial
	
	if value == null:
		shaderBlurState = not shaderBlurState
		(shader_material).set_shader_parameter("go", shaderBlurState)
		(shader_material2).set_shader_parameter("go", shaderBlurState)
	elif (value is bool):

		shaderBlurState = value
		(shader_material).set_shader_parameter("go", shaderBlurState)
		(shader_material2).set_shader_parameter("go", shaderBlurState)

func buttonSelect(stage: StageReference, portalEntered: Portal) -> void:
	freezeScene(false)

	Global.setPortal(currentStage.name, portalEntered.direction, stage)

	blur(false)
	loadScene(stage)
	changeStage(stage, portalEntered, true)

func changeStage(stage: StageReference, portalEntered: Portal, new:bool = false) -> void:
	print("Changing stage to %s via portal %d"%[stage.name, portalEntered.direction])
	var oldStage: StageReference;
	for child in $VPContainer/frameVP.get_children():
		if child.is_in_group("stage"):
			oldStage = StageReference.new(child, "")
			child.queue_free()
			$VPContainer/frameVP.call_deferred("remove_child",child)
	currentStage = stage
	call_deferred("loadSceneInstance", stage, portalEntered.direction, oldStage, new)
	
func loadSceneInstance(stage: StageReference, direction: Portal.portalDirection, oldStage: StageReference, new:bool) -> void:
	var packed_scene = sceneCache[stage.name]
	if not packed_scene or not packed_scene is PackedScene:
		print("Error: Scene for %s is not loaded properly." % stage.name)
		return
	var instance = packed_scene.instantiate()
	if not instance or not instance is Node2D:
		print("Error: Failed to instantiate scene for %s." % stage.name)
		return
	$VPContainer/frameVP.add_child(instance)
	portalUpdate(oldStage, direction, instance, stage, new)

func portalUpdate(oldStage: StageReference, direction: Portal.portalDirection, instance: Node2D, stage:StageReference, new:bool) -> void:
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
		
	if new:
		Global.setPortal(stage.name, Portal.reverseDir(direction), oldStage)
	
	player.position = exitPortal.position + exitPortal.exitOffset()
	$VPContainer/frameVP/Camera2D.position = player.position
	player.collision_layer = 2
	# remove outers...
