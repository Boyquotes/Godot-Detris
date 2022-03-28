extends Node


var title_scene : PackedScene = preload("res://TitleScreen.tscn")
var game_scene : PackedScene = preload("res://Playfield.tscn")


func _init() -> void:
	randomize()


func _on_TitleScreen_game_started() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene_to(game_scene)


func _on_Matrix_game_lost() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene_to(title_scene)
