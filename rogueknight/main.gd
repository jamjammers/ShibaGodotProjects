extends Node

@export var mob_scene: PackedScene
var score

func _ready():
	pass
	
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	get_tree().call_group("mobs", "queue_free")

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
	$HUD.updateScore(score)
	$HUD.showMessage("Get Ready")

func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate();
	
	var mobSpawnLocation = $MobPath/spawnLocation;
	mobSpawnLocation.progress_ratio = randf();
	
	mob.position = mobSpawnLocation.position;
	
	var direction = mobSpawnLocation.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	
	mob.rotation = direction

	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob); 


func _on_score_timer_timeout() -> void:
	score+=1;
	$HUD.updateScore(score)
	$MobTimer.wait_time = pow(1.1,5-score)+0.1


func _on_start_timer_timeout() -> void:
	$MobTimer.start();
	$ScoreTimer.start();
