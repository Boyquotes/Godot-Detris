extends Node2D


signal game_started ()


func _ready() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	connect("game_started", Global, "_on_TitleScreen_game_started")
	$Control/HiScore.text = "Hi: %07d" % Global.high_score


func _process(_delta : float) -> void:
	if (
		InputFilter.just_pressed("mino_clockwise")
		or InputFilter.just_pressed("mino_anticlockwise")
	):
		set_process(false)
		$AudioStreamPlayer.play()
		$Control/StartLabel.hide()
		$BlinkTimer.start()
		$StartTimer.start()


func _on_BlinkTimer_timeout() -> void:
	if $Control/StartLabel.visible:
		$Control/StartLabel.hide()
	else:
		$Control/StartLabel.show()


func _on_StartTimer_timeout() -> void:
	emit_signal("game_started")
