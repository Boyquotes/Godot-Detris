extends Node


signal key_pressed (input_event_key)


enum {
	UNPRESSED,
	JUST_PRESSED,
	HELD_START,
	HELD_ECHO,
	ECHO,
	JUST_RELEASED,
}


export var echo_start_frames := 10
export var echo_frames := 2

var actions := {}


func _init() -> void:
	for a in InputMap.get_actions():
		actions[a] = {
			"state": UNPRESSED,
			"held_frames": 0,
		}


func _process(_delta : float) -> void:
	for a in InputMap.get_actions():
		if Input.is_action_pressed(a):
			match actions[a].state:
				UNPRESSED, JUST_RELEASED:
					actions[a].state = JUST_PRESSED
				JUST_PRESSED:
					actions[a].state = HELD_START
					actions[a].held_frames = 1
				HELD_START:
					if actions[a].held_frames >= echo_start_frames:
						actions[a].state = HELD_ECHO
						actions[a].held_frames = 0
					else:
						actions[a].held_frames += 1
				HELD_ECHO:
					if actions[a].held_frames >= echo_frames:
						actions[a].state = ECHO
					else:
						actions[a].held_frames += 1
				ECHO:
					actions[a].state = HELD_ECHO
					actions[a].held_frames = 0
		else:
			match actions[a].state:
				UNPRESSED:
					pass
				JUST_PRESSED, HELD_START, HELD_ECHO, ECHO:
					actions[a].state = JUST_RELEASED
					actions[a].held_frames = 0
				JUST_RELEASED:
					actions[a].state = UNPRESSED


func _unhandled_key_input(event : InputEventKey) -> void:
	if event.is_pressed():
		emit_signal("key_pressed", event)


func just_pressed(action : String) -> bool:
	return actions[action].state == JUST_PRESSED


func just_pressed_or_echo(action : String) -> bool:
	return (
		actions[action].state == JUST_PRESSED
		or actions[action].state == ECHO
	)


func pressed(action : String) -> bool:
	return (
		actions[action].state == JUST_PRESSED
		or actions[action].state == HELD_START
		or actions[action].state == HELD_ECHO
		or actions[action].state == ECHO
	)


# Actions are broken up by 'category', matched by the string preceding their first
# underscore - e.g. ui_up, ui_down, ui_accept; and mino_clockwise, mino_left.
# Two actions in a single category should never have overlapping events, so
# remap_action() automatically swaps events if the new mapping would cause one
# to emerge.
func remap_action(action : String, event : InputEventKey) -> void:
	var category := action.split("_", true, 1)[0]
	for a in InputMap.get_actions():
		if a == action or not a.begins_with(category):
			continue
		if InputMap.action_has_event(a, event):
			# Swap mapping of 'a' and 'action'
			InputMap.action_erase_events(a)
			InputMap.action_add_event(a, InputMap.get_action_list(action)[0])

	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
