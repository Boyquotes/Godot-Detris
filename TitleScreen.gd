extends Node2D


signal game_started ()


func _ready() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	connect("game_started", Global, "_on_TitleScreen_game_started")


func _input(event : InputEvent) -> void:
	if (
		event.is_action_pressed("mino_clockwise")
		or event.is_action_pressed("mino_anticlockwise")
	):
		$AudioStreamPlayer.play()
		$Control/Label.hide()
		$BlinkTimer.start()
		$StartTimer.start()


func _on_BlinkTimer_timeout() -> void:
	if $Control/Label.visible:
		$Control/Label.hide()
	else:
		$Control/Label.show()


func _on_StartTimer_timeout() -> void:
	emit_signal("game_started")
