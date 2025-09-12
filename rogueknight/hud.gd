extends CanvasLayer

signal startGame


func showMessage(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	showMessage("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func updateScore(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	$StartButton.hide()
	startGame.emit()

func _on_message_timer_timeout():
	$Message.hide()
