extends Node2D


signal back_selected ()


export var highlight_font : DynamicFont

var selected_option := 0 setget set_selected_option

onready var options = [
	{
		"text_label": $Control/TurnLeft,
		"action": "mino_anticlockwise",
	},
	{
		"text_label": $Control/TurnRight,
		"action": "mino_clockwise",
	},
	{
		"text_label": $Control/MoveLeft,
		"action": "mino_left",
	},
	{
		"text_label": $Control/MoveRight,
		"action": "mino_right",
	},
	{
		"text_label": $Control/SoftDrop,
		"action": "mino_soft_drop",
	},
	{
		"text_label": $Control/HardDrop,
		"action": "mino_hard_drop",
	},
	{
		"text_label": $Control/Hold,
		"action": "mino_hold",
	},
	{
		"text_label": $Control/Back,
		"action": null,
	},
]


func _ready() -> void:
	set_selected_option(0)
	# warning-ignore: RETURN_VALUE_DISCARDED
	connect("back_selected", Global, "_on_InputMapScreen_back_selected")
	for o in options:
		if not o.action:
			continue
		var name_label : Label = o.text_label.get_node("ButtonName")
		var action = InputMap.get_action_list(o.action)[0]
		name_label.text = action.as_text()


func _process(_delta : float) -> void:
	if InputFilter.just_pressed("ui_accept"):
		if options[selected_option].action:
			$EditSFX.play()
			set_process(false)
			var new_key : InputEventKey = yield(InputFilter, "key_pressed")
			print(new_key.as_text())
			$ConfirmSFX.play()
			# Wait one full frame to prevent input getting consumed by _process.
			# As we're effectively mid-frame when this is reached, it requires
			# two idle_frame delays.
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			set_process(true)
		else:
			set_process(false)
			$BackSFX.play()
			yield($BackSFX, "finished")
			emit_signal("back_selected")
	elif InputFilter.just_pressed("ui_down"):
		$SelectSFX.play()
		set_selected_option((selected_option + 1) % options.size())
	elif InputFilter.just_pressed("ui_up"):
		$SelectSFX.play()
		set_selected_option((selected_option - 1) % options.size())


func set_selected_option(option_ : int) -> void:
	var old_label : Label = options[selected_option].text_label
	var new_label : Label = options[option_].text_label
	old_label.add_font_override("font", null)
	new_label.add_font_override("font", highlight_font)
	selected_option = option_
