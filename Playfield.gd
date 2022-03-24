extends Node2D


func _unhandled_input(event):
	print(event.to_string())


func _on_Matrix_queued_mino_requested() -> void:
	print("Matrix requested queued mino")
	var queued = $Queue.pop()
	$Matrix.spawn_mino(queued)


func _on_Matrix_held_mino_requested() -> void:
	print("Matrix requested held mino")
	var new_shape = $Hold.swap_mino($Matrix.mino.shape)
	if not new_shape:
		new_shape = $Queue.pop()
	$Matrix.spawn_mino(new_shape)
