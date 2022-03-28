extends Node2D


func _ready() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	ScoreManager.connect("scores_updated", self, "_on_ScoreManager_scores_updated")


func _on_ScoreManager_scores_updated() -> void:
	print(ScoreManager.current_score)
