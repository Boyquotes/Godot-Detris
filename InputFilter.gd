extends Node


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


func _input(event : InputEvent) -> void:
	for a in InputMap.get_actions():
		if event.is_action(a):
			get_tree().set_input_as_handled()


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
