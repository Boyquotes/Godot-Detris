extends Node2D


var mino : Mino = null setget set_mino


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(80, 80)), Color.gray)


func swap_mino(new_mino : Mino) -> Mino:
	var old = mino
	set_mino(new_mino)
	return old


func set_mino(mino_ : Mino) -> void:
	if mino:
		remove_child(mino)

	if mino_:
		mino_.position = Vector2.ZERO
		add_child(mino_)

	mino = mino_
