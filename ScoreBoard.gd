extends Node2D


func _ready() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	ScoreManager.connect("scores_updated", self, "_on_ScoreManager_scores_updated")
	update_labels()


func update_labels() -> void:
	$Panel/ScoreNumber.text = "%07d" % ScoreManager.current_score
	$Panel/HiScoreNumber.text = "%07d" % ScoreManager.high_score
	$Panel/LevelNumber.text = "%d" % ScoreManager.current_level


func _on_ScoreManager_scores_updated() -> void:
	update_labels()
