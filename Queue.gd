extends Node2D


var queue : PoolIntArray = []


func _init() -> void:
	refresh_queue()


func _ready() -> void:
	update_minos()


func _draw() -> void:
	draw_rect(Rect2(position, Vector2(80, 300)), Color.gray)


func pop_queue() -> int:
	var ret = queue[0]
	queue.remove(0)
	update_minos()
	if queue.size() < 4:
		refresh_queue()
	return ret


func update_minos() -> void:
	$Mino.set_shape(queue[0])
	$Mino2.set_shape(queue[1])
	$Mino3.set_shape(queue[2])
	$Mino4.set_shape(queue[3])


func refresh_queue() -> void:
	for i in 7:
		queue.push_back(randi() % 7)
