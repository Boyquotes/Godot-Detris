extends Node2D


const WIDTH := 10
const HEIGHT := 20


var grid : PoolIntArray = []


func _init() -> void:
	for i in WIDTH * HEIGHT:
		grid.push_back(0)


func _draw() -> void:
	for i in grid.size():
		if grid[i]:
			draw_texture(Mino.TEXTURES[grid[i]], Vector2(i % WIDTH, i / WIDTH) * 16)
