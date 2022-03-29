extends Node2D


func _ready() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	Global.connect("scores_updated", self, "_on_Global_scores_updated")
	# warning-ignore: RETURN_VALUE_DISCARDED
	Global.connect("lines_updated", self, "_on_Global_lines_updated")
	# warning-ignore: RETURN_VALUE_DISCARDED
	Global.connect("level_updated", self, "_on_Global_level_updated")
	update_labels()


func update_labels() -> void:
	$ScoreNumber.text = "%07d" % Global.current_score
	$HiScoreNumber.text = "%07d" % Global.high_score
	$LinesNumber.text = "%03d" % Global.current_lines
	$LevelNumber.text = "%d" % Global.current_level


func _on_Global_scores_updated() -> void:
	update_labels()


func _on_Global_lines_updated() -> void:
	update_labels()


func _on_Global_level_updated() -> void:
	update_labels()
