extends Node2D


var mino : Mino = null


func swap_mino(new_shape : int) -> int:
	if not mino:
		mino = Mino.new()
		add_child(mino)
		mino.set_shape(new_shape)
		mino.position = Vector2.ONE * 8
		return 0
	else:
		var old_shape = mino.shape
		mino.set_shape(new_shape)
		mino.position = Vector2.ONE * 8
		return old_shape
