extends Node2D


signal queued_mino_requested
signal held_mino_requested


const WIDTH := 10
const HEIGHT := 20


var grid : PoolIntArray = []
var mino := {
	"shape": 0,
	"rot": 0,
	"x": 0,
	"y": 0,
}


func _init() -> void:
	for i in WIDTH * HEIGHT:
		grid.push_back(0)


func _ready() -> void:
	emit_signal("queued_mino_requested")


func _process(_delta : float) -> void:
	if mino.shape == 0: # Locked out of actions until we get a mino
		return

	if Input.is_action_just_pressed("mino_hold"):
		hold_mino()
		return

	if Input.is_action_just_pressed("mino_hard_drop"):
		hard_drop_mino()
		return

	if Input.is_action_just_pressed("mino_soft_drop"):
		soft_drop_mino()

	if Input.is_action_just_pressed("mino_right"):
		translate_mino(true)
	elif Input.is_action_just_pressed("mino_left"):
		translate_mino(false)

	if Input.is_action_just_pressed("mino_clockwise"):
		rotate_mino(true)
	elif Input.is_action_just_pressed("mino_anticlockwise"):
		rotate_mino(false)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(WIDTH, HEIGHT) * 16), Color.gray)
	for i in WIDTH:
		for j in HEIGHT:
			if grid[i + j * WIDTH]:
				var r = Rect2(Vector2(i, j) * 16, Vector2.ONE * 16)
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


# Drops mino as far as possible up to distance. Returns actual distance moved.
func drop_mino(distance : int) -> int:
	var original_y = mino.y

	remove_mino_from_grid()
	for i in distance:
		mino.y += 1
		if not can_fit_in_grid():
			mino.y -= 1
			break
	add_mino_to_grid()

	return mino.y - original_y


func translate_mino(right : bool) -> void:
	remove_mino_from_grid()
	var tl := 1 if right else -1
	mino.x += tl
	if not can_fit_in_grid():
		mino.x -= tl
	add_mino_to_grid()


func rotate_mino(clockwise : bool) -> void:
	remove_mino_from_grid()
	var rot := 1 if clockwise else -1
	mino.rot = (mino.rot + rot) % 4
	if not can_fit_in_grid():
		# TODO: Test if it can be fit by shifting slightly
		mino.rot = (mino.rot - rot) % 4
	add_mino_to_grid()


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
		"x": 4,
		"y": 0,
	}
	# TODO: if not can_fit_in_grid(), lose
	add_mino_to_grid()


func lock_mino() -> void:
	emit_signal("queued_mino_requested")


func hold_mino() -> void:
	remove_mino_from_grid()
	emit_signal("held_mino_requested")


func clear_line(line : int) -> void:
	var update_array : PoolVector2Array = []

	for i in WIDTH:
		update_array.push_back(Vector2(i + WIDTH * line, 0))
		for j in line:
			update_array.push_back(Vector2(i + WIDTH * (j + 1), grid[i + WIDTH * j]))

	update_grid(update_array, true)


func update_grid(new_tiles : PoolVector2Array, update_draw : bool) -> void:
	for t in new_tiles:
		grid[t.x] = t.y

	if update_draw:
		update()

	
func _on_DropTimer_timeout() -> void:
	if mino.shape:
		soft_drop_mino()
