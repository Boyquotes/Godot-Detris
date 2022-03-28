extends Node


export var points_single := 100
export var points_double := 400
export var points_triple := 900
export var points_detris := 1600
export var points_softdrop := 1
export var points_harddrop := 20

var current_score := 0
var current_level := 0
var high_score := 0


func increment_score(points : int) -> void:
	current_score += points
	if current_score > high_score:
		high_score = current_score


func _on_Matrix_soft_dropped() -> void:
	increment_score(points_softdrop)


func _on_Matrix_hard_dropped() -> void:
	increment_score(points_harddrop)


func _on_Matrix_lines_cleared(lines : int) -> void:
	match lines:
		1:
			increment_score(points_single)
		2:
			increment_score(points_double)
		3:
			increment_score(points_triple)
		4:
			increment_score(points_detris)
		_:
			assert(false, "Unexpected number of lines cleared: %d" % lines)
