extends Node2D


signal queued_mino_requested ()
signal held_mino_requested ()
signal lines_cleared (amount)
signal hard_dropped ()
signal game_lost ()


const WIDTH := 10
const HEIGHT := 20
const SHADOW_TEX = preload("res://textures/shadow.png")

const DROP_TIMES := PoolRealArray([
	1.0,
	0.9,
	0.8,
	0.7,
	0.6,
	0.5,
	0.4,
	0.3,
	0.2,
	0.1,
])
const LOCK_TIMES := PoolRealArray([
	2.0,
	1.9,
	1.8,
	1.7,
	1.6,
	1.5,
	1.4,
	1.3,
	1.2,
	1.1,
	1.0,
])


var grid : PoolIntArray = []
var mino := {
	"shape": 0,
	"rot": 0,
	"x": 0,
	"y": 0,
}
var just_held := false

var drop_timeout := 1.0
var lock_timeout := 2.0


func _init() -> void:
	for i in WIDTH * HEIGHT:
		grid.push_back(0)


func _ready() -> void:
	$Panel.rect_size = Vector2(WIDTH, HEIGHT) * Mino.SIZE
	update_timers()
	emit_signal("queued_mino_requested")
	# warning-ignore: RETURN_VALUE_DISCARDED
	Global.connect("level_updated", self, "_on_Global_level_updated")


func _unhandled_key_input(event : InputEventKey) -> void:
	if mino.shape == 0: # Locked out of actions until we get a mino
		return

	if event.is_action_pressed("mino_hold") and not just_held:
		hold_mino()
		return

	if event.is_action_pressed("mino_hard_drop"):
		emit_signal("hard_dropped")
		hard_drop_mino()
		return

	if event.is_action_pressed("mino_soft_drop", true):
		soft_drop_mino()

	if event.is_action_pressed("mino_right", true):
		translate_mino(true)
	elif event.is_action_pressed("mino_left", true):
		translate_mino(false)

	if event.is_action_pressed("mino_clockwise"):
		rotate_mino(true)
	elif event.is_action_pressed("mino_anticlockwise"):
		rotate_mino(false)


func _draw() -> void:
	# Draw shadow mino first
	var drop_distance = drop_mino(20, true)
	for i in 4:
		for j in 4:
			if Mino.SHAPES[mino.shape][mino.rot][i + 4 * j]:
				var target_x = mino.x + i
				var target_y = mino.y + j + drop_distance
				if not grid[target_x + WIDTH * target_y]:
					var r = Rect2(Vector2(target_x, target_y) * Mino.SIZE, Vector2.ONE * Mino.SIZE)
					draw_texture_rect(SHADOW_TEX, r, false)

	for i in WIDTH:
		for j in HEIGHT:
			if grid[i + j * WIDTH]:
				var r = Rect2(Vector2(i, j) * Mino.SIZE, Vector2.ONE * Mino.SIZE)
				draw_texture_rect(Mino.TEXTURES[grid[i + j * WIDTH]], r, false)


func can_fit_in_grid() -> bool:
	for i in 4:
		for j in 4:
			if Mino.SHAPES[mino.shape][mino.rot][i + 4 * j]:
				if (
					mino.x + i < 0
					or mino.x + i >= WIDTH
					or mino.y + j < 0
					or mino.y + j >= HEIGHT
					or grid[mino.x + i + WIDTH * (mino.y + j)] != 0
				):
					return false

	return true


# Drops mino all the way down and locks
func hard_drop_mino() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	drop_mino(HEIGHT)
	lock_mino()


# Drops mino one tile, or locks if impossible
func soft_drop_mino() -> void:
	if drop_mino(1) == 0:
		lock_mino()
	else:
		if can_drop_mino():
			$LockTimer.stop()
			$DropTimer.start()
		else:
			$DropTimer.stop()
			$LockTimer.start()


# Drops mino as far as possible up to distance. Returns actual distance moved.
func drop_mino(distance : int, dry_run : bool = false) -> int:
	var original_y = mino.y

	remove_mino_from_grid()
	for i in distance:
		mino.y += 1
		if not can_fit_in_grid():
			mino.y -= 1
			break
	var final_y = mino.y
	if dry_run:
		mino.y = original_y
	add_mino_to_grid()

	return final_y - original_y


func can_drop_mino() -> bool:
	return drop_mino(1, true) == 1


func translate_mino(right : bool) -> void:
	remove_mino_from_grid()
	var tl := 1 if right else -1
	mino.x += tl
	if not can_fit_in_grid():
		mino.x -= tl
	add_mino_to_grid()

	if can_drop_mino():
		$LockTimer.stop()
		if $DropTimer.is_stopped():
			$DropTimer.start()
	else:
		$DropTimer.stop()
		if $LockTimer.is_stopped():
			$LockTimer.start()


func rotate_mino(clockwise : bool) -> void:
	remove_mino_from_grid()
	var rot := 1 if clockwise else -1
	mino.rot = (mino.rot + rot) % 4
	if not can_fit_in_grid():
		# TODO: Test if it can be fit by shifting slightly
		mino.rot = (mino.rot - rot) % 4
	else:
		$SpinSFX.play()
	add_mino_to_grid()

	if can_drop_mino():
		$LockTimer.stop()
		if $DropTimer.is_stopped():
			$DropTimer.start()
	else:
		$DropTimer.stop()
		$LockTimer.start()


# Does not redraw the grid, expecting the mino to be re-added elsewhere
func remove_mino_from_grid() -> void:
	var update_array : PoolVector2Array = []

	for i in 4:
		for j in 4:
			if Mino.SHAPES[mino.shape][mino.rot][i + 4 * j]:
				var loc = mino.x + i + WIDTH * (mino.y + j)
				update_array.push_back(Vector2(loc, 0))

	update_grid(update_array, false)


# Redraws the grid
func add_mino_to_grid() -> void:
	var update_array : PoolVector2Array = []

	for i in 4:
		for j in 4:
			if Mino.SHAPES[mino.shape][mino.rot][i + 4 * j]:
				var loc = mino.x + i + WIDTH * (mino.y + j)
				update_array.push_back(Vector2(loc, mino.shape))

	update_grid(update_array, true)


func spawn_mino(shape : int) -> void:
	mino = {
		"shape": shape,
		"rot": 0,
		"x": 3,
		"y": 0,
	}
	var has_lost := not can_fit_in_grid()
	add_mino_to_grid()
	if has_lost:
		$GameOverSFX.play()
		$DropTimer.stop()
		set_process_unhandled_key_input(false)
		yield($GameOverSFX, "finished")
		emit_signal("game_lost")
	else:
		if can_drop_mino():
			$LockTimer.stop()
			$DropTimer.start()
		else:
			$DropTimer.stop()
			$LockTimer.start()


func lock_mino() -> void:
	just_held = false
	$LockSFX.play()
	clear_completed_lines()
	emit_signal("queued_mino_requested")


func hold_mino() -> void:
	just_held = true
	remove_mino_from_grid()
	$HoldSFX.play()
	emit_signal("held_mino_requested")


func clear_completed_lines() -> void:
	var cleared : PoolIntArray = []

	for j in HEIGHT:
		var complete = true
		for i in WIDTH:
			if not grid[i + WIDTH * j]:
				complete = false
				break
		if complete:
			cleared.push_back(j)

	if cleared.size() > 0:
		$LineClearSFX.play()
		delete_cleared_lines(cleared)
		drop_above_lines(cleared)
		emit_signal("lines_cleared", cleared.size())


# Replace cleared lines with blank space
func delete_cleared_lines(lines : PoolIntArray) -> void:
	var update_array : PoolVector2Array = []
	for line in lines:
		for i in WIDTH:
			update_array.push_back(Vector2(i + WIDTH * line, 0))
	update_grid(update_array, true)


# Apply gravity above cleared lines, which must be sorted from top to bottom
func drop_above_lines(lines : PoolIntArray) -> void:
	for line in lines:
		var update_array : PoolVector2Array = []
		for i in WIDTH:
			for j in line:
				update_array.push_back(Vector2(
						i + WIDTH * (j + 1),
						grid[i + WIDTH * j]
				))
		update_grid(update_array, true)


func update_grid(new_tiles : PoolVector2Array, update_draw : bool) -> void:
	for t in new_tiles:
		grid[t.x] = t.y

	if update_draw:
		update()


func update_timers() -> void:
	var drop_idx := min(Global.current_level, DROP_TIMES.size() - 1)
	var lock_idx := min(Global.current_level, LOCK_TIMES.size() - 1)
	$DropTimer.set_wait_time(DROP_TIMES[drop_idx])
	$LockTimer.set_wait_time(LOCK_TIMES[lock_idx])


func _on_DropTimer_timeout() -> void:
	if mino.shape:
		soft_drop_mino()


func _on_LockTimer_timeout() -> void:
	if mino.shape:
		lock_mino()


func _on_Global_level_updated() -> void:
	update_timers()
