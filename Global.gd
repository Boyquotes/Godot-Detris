extends Node


signal scores_updated
signal lines_updated
signal level_updated


const LINE_SCORES := PoolIntArray([
	0,
	100,
	300,
	600,
	1000,
])
const TSPIN_SCORES := PoolIntArray([
	0,
	300,
	800,
	1400,
])

export var points_harddrop := 10
export var lines_per_level := 10

var current_score := 0 setget set_score
var current_level := 1
var current_lines := 0 setget set_lines
var high_score := 0

var title_scene : PackedScene = preload("res://TitleScreen.tscn")
var title_options := {
	"Start": preload("res://Playfield.tscn"),
	"Options": preload("res://TitleScreen.tscn"),
}


func _init() -> void:
	randomize()
	reset()
	load_game()


func reset() -> void:
	set_score(0)
	set_lines(0)
	current_level = 1


func load_game() -> void:
	var file : File = File.new()
	if not file.file_exists("user://save.json"):
		print("No save data exists, skipping load")
		return

	var err := file.open("user://save.json", File.READ)
	if err:
		push_error("Could not open file for read: error %d" % err)
		return

	if file.get_position() >= file.get_len():
		push_error("Could not load data: save file incomplete or corrupt")
		return

	var data_str := file.get_line()
	var data_obj = parse_json(data_str)
	if data_obj is Dictionary and "high_score" in data_obj:
		high_score = int(data_obj.high_score)

	file.close()


func save_game() -> void:
	var file : File = File.new()
	var err := file.open("user://save.json", File.WRITE)
	if err:
		push_error("Could not open file for write: error %d" % err)
		return

	var data_obj := {
		"high_score": high_score,
	}
	file.store_line(to_json(data_obj))

	file.close()


func increment_score(points : int) -> void:
	set_score(current_score + points)


func increment_lines(lines : int) -> void:
	set_lines(current_lines + lines)


func set_score(score_ : int) -> void:
	current_score = score_
	if current_score > high_score:
		high_score = current_score
	emit_signal("scores_updated")


func set_lines(lines_ : int) -> void:
	current_lines = lines_
	emit_signal("lines_updated")
	# warning-ignore: INTEGER_DIVISION
	var target_level = current_lines / lines_per_level
	if target_level > current_level:
		current_level = target_level
		emit_signal("level_updated")


func _on_Matrix_hard_dropped() -> void:
	increment_score(points_harddrop)


func _on_Matrix_lines_cleared(lines : int, tspin : bool) -> void:
	var scores = TSPIN_SCORES if tspin else LINE_SCORES
	assert(lines <= scores.size() - 1, "Unexpected number of lines cleared: %d" % lines)
	increment_score(current_level * scores[lines])
	increment_lines(lines)


func _on_TitleScreen_option_selected(option : String) -> void:
	if not option in title_options:
		push_error("Selected unsupported option %s on TitleScreen" % option)
	else:
		# warning-ignore: RETURN_VALUE_DISCARDED
		get_tree().change_scene_to(title_options[option])


func _on_Matrix_gameplay_finished() -> void:
	save_game()


func _on_Matrix_game_lost() -> void:
	reset()
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene_to(title_scene)
