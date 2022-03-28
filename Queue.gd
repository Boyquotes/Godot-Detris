extends Node2D


var queue : PoolIntArray = []


func _init() -> void:
	refresh_queue()


func _ready() -> void:
	update_minos()


func pop() -> int:
	var ret = queue[0]
	queue.remove(0)
	if queue.size() < 4:
		refresh_queue()
	update_minos()
	return ret


func update_minos() -> void:
	$Mino.set_shape(queue[0])
	$Mino2.set_shape(queue[1])
	$Mino3.set_shape(queue[2])
	$Mino4.set_shape(queue[3])


# Appends a random permutation of all 7 minos to the queue
func refresh_queue() -> void:
	var bag_unmixed : PoolIntArray = [1, 2, 3, 4, 5, 6, 7]
	var bag_mixed : PoolIntArray = []

	for i in 7:
		var idx = randi() % bag_unmixed.size()
		var r = bag_unmixed[idx]
		bag_unmixed.remove(idx)
		bag_mixed.push_back(r)

	queue.append_array(bag_mixed)
