extends Node2D


func _ready() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	$Matrix.connect("hard_dropped", Global, "_on_Matrix_hard_dropped")
	# warning-ignore: RETURN_VALUE_DISCARDED
	$Matrix.connect("lines_cleared", Global, "_on_Matrix_lines_cleared")
	# warning-ignore: RETURN_VALUE_DISCARDED
	$Matrix.connect("game_lost", Global, "_on_Matrix_game_lost")


func _on_Matrix_queued_mino_requested() -> void:
	var queued = $Queue.pop()
	$Matrix.spawn_mino(queued)


func _on_Matrix_held_mino_requested() -> void:
	var new_shape = $Hold.swap_mino($Matrix.mino.shape)
	if not new_shape:
		new_shape = $Queue.pop()
	$Matrix.spawn_mino(new_shape)
