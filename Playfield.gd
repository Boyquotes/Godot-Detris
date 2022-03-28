extends Node2D


func _ready() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	$Matrix.connect("soft_dropped", ScoreManager, "_on_Matrix_soft_dropped")
	# warning-ignore: RETURN_VALUE_DISCARDED
	$Matrix.connect("hard_dropped", ScoreManager, "_on_Matrix_hard_dropped")
	# warning-ignore: RETURN_VALUE_DISCARDED
	$Matrix.connect("lines_cleared", ScoreManager, "_on_Matrix_lines_cleared")


func _on_Matrix_queued_mino_requested() -> void:
	var queued = $Queue.pop()
	$Matrix.spawn_mino(queued)


func _on_Matrix_held_mino_requested() -> void:
	var new_shape = $Hold.swap_mino($Matrix.mino.shape)
	if not new_shape:
		new_shape = $Queue.pop()
	$Matrix.spawn_mino(new_shape)
