extends Node2D


signal option_selected (option)


export var highlight_font : DynamicFont

var selected_label := 0 setget set_selected_label

onready var options = [
	$Control/StartLabel,
	$Control/OptionsLabel,
]


func _ready() -> void:
	set_selected_label(0)
	# warning-ignore: RETURN_VALUE_DISCARDED
	connect("option_selected", Global, "_on_TitleScreen_option_selected")
	$Control/HiScore.text = "Hi: %07d" % Global.high_score


func _process(_delta : float) -> void:
	if InputFilter.just_pressed("ui_accept"):
		if options[selected_label] == $Control/StartLabel:
			set_process(false)
			$StartGameSFX.play()
			options[selected_label].hide()
			$BlinkTimer.start()
			$StartTimer.start()
			yield($StartTimer, "timeout")
			emit_signal("option_selected", options[selected_label].text)
		else:
			set_process(false)
			$StartOptionsSFX.play()
			options[selected_label].hide()
			yield($StartOptionsSFX, "finished")
			emit_signal("option_selected", options[selected_label].text)
	elif InputFilter.just_pressed("ui_down"):
		$SelectSFX.play()
		set_selected_label((selected_label + 1) % options.size())
	elif InputFilter.just_pressed("ui_up"):
		$SelectSFX.play()
		set_selected_label((selected_label - 1) % options.size())


func set_selected_label(label_ : int) -> void:
	var old_label : Label = options[selected_label]
	var new_label : Label = options[label_]
	old_label.add_font_override("font", null)
	new_label.add_font_override("font", highlight_font)
	selected_label = label_


func _on_BlinkTimer_timeout() -> void:
	if options[selected_label].visible:
		options[selected_label].hide()
	else:
		options[selected_label].show()
