class_name Mino
extends Node2D


enum {
	T = 1,
	O,
	I,
	S,
	Z,
	L,
	J,
}

const SIZE = 24

const TEXTURES = {
	T: preload("res://textures/T.png"),
	O: preload("res://textures/O.png"),
	I: preload("res://textures/I.png"),
	S: preload("res://textures/S.png"),
	Z: preload("res://textures/Z.png"),
	L: preload("res://textures/L.png"),
	J: preload("res://textures/J.png"),
}

const SHAPES = {
	T: [
		[
			0,0,0,0,
			0,1,0,0,
			1,1,1,0,
			0,0,0,0,
		],
		[
			0,0,0,0,
			0,1,0,0,
			0,1,1,0,
			0,1,0,0,
		],
		[
			0,0,0,0,
			0,0,0,0,
			1,1,1,0,
			0,1,0,0,
		],
		[
			0,0,0,0,
			0,1,0,0,
			1,1,0,0,
			0,1,0,0,
		],
	],
	O: [
		[
			0,0,0,0,
			0,1,1,0,
			0,1,1,0,
			0,0,0,0,
		],
		[
			0,0,0,0,
			0,1,1,0,
			0,1,1,0,
			0,0,0,0,
		],
		[
			0,0,0,0,
			0,1,1,0,
			0,1,1,0,
			0,0,0,0,
		],
		[
			0,0,0,0,
			0,1,1,0,
			0,1,1,0,
			0,0,0,0,
		],
	],
	I: [
		[
			0,0,0,0,
			1,1,1,1,
			0,0,0,0,
			0,0,0,0,
		],
		[
			0,0,1,0,
			0,0,1,0,
			0,0,1,0,
			0,0,1,0,
		],
		[
			0,0,0,0,
			0,0,0,0,
			1,1,1,1,
			0,0,0,0,
		],
		[
			0,1,0,0,
			0,1,0,0,
			0,1,0,0,
			0,1,0,0,
		],
	],
	S: [
		[
			0,0,0,0,
			0,1,1,0,
			1,1,0,0,
			0,0,0,0,
		],
		[
			0,0,0,0,
			0,1,0,0,
			0,1,1,0,
			0,0,1,0,
		],
		[
			0,0,0,0,
			0,0,0,0,
			0,1,1,0,
			1,1,0,0,
		],
		[
			0,0,0,0,
			1,0,0,0,
			1,1,0,0,
			0,1,0,0,
		],
	],
	Z: [
		[
			0,0,0,0,
			1,1,0,0,
			0,1,1,0,
			0,0,0,0,
		],
		[
			0,0,0,0,
			0,0,1,0,
			0,1,1,0,
			0,1,0,0,
		],
		[
			0,0,0,0,
			0,0,0,0,
			1,1,0,0,
			0,1,1,0,
		],
		[
			0,0,0,0,
			0,1,0,0,
			1,1,0,0,
			1,0,0,0,
		],
	],
	L: [
		[
			0,0,0,0,
			0,0,1,0,
			1,1,1,0,
			0,0,0,0,
		],
		[
			0,0,0,0,
			0,1,0,0,
			0,1,0,0,
			0,1,1,0,
		],
		[
			0,0,0,0,
			0,0,0,0,
			1,1,1,0,
			1,0,0,0,
		],
		[
			0,0,0,0,
			1,1,0,0,
			0,1,0,0,
			0,1,0,0,
		],
	],
	J: [
		[
			0,0,0,0,
			1,0,0,0,
			1,1,1,0,
			0,0,0,0,
		],
		[
			0,0,0,0,
			0,1,1,0,
			0,1,0,0,
			0,1,0,0,
		],
		[
			0,0,0,0,
			0,0,0,0,
			1,1,1,0,
			0,0,1,0,
		],
		[
			0,0,0,0,
			0,1,0,0,
			0,1,0,0,
			1,1,0,0,
		],
	],
}


var shape = T setget set_shape
var rot := 0 setget set_rot


func _draw() -> void:
	for i in 4:
		for j in 4:
			if SHAPES[shape][rot][i + 4 * j]:
				var r = Rect2(Vector2(i, j) * SIZE, Vector2.ONE * SIZE)
				draw_texture_rect(TEXTURES[shape], r, false)


func set_shape(shape_ : int) -> void:
	assert(TEXTURES[shape], "Invalid shape %d set" % shape_)
	shape = shape_
	update()


func set_rot(rot_ : int) -> void:
	assert(0 <= rot and rot <= 3, "Invalid rotation %d set" % rot_)
	rot = rot_
	update()


func get_bitfield() -> PoolIntArray:
	return SHAPES[shape][rot]
