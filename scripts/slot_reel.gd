extends Control

var symbol: = "cherry"
var spinning: = false
var clock: = 0.0
var index: = 0
var rows: Array = []
var lit: Array = []
const SYMBOLS: = ["cherry", "bell", "star", "seven"]

func set_reel(value: String, running: bool, elapsed: float, reel_index: int) -> void :
	symbol = value
	spinning = running and elapsed < 1.6 + reel_index * 0.65
	clock = elapsed
	index = reel_index
	queue_redraw()

func _draw() -> void :
	var cells: = 3 if rows.size() == 3 else 1
	var height: = size.y / cells
	if cells == 3:
		for row in lit: draw_rect(Rect2(0, height * row, size.x, height), Color("866335"))
	if spinning:
		var travel: = clock * 145.0 + index * 13
		var cycle: = int(travel / height)
		var offset: = fmod(travel, height)
		for j in range(-1, cells + 1):
			draw_symbol(SYMBOLS[posmod(cycle + j, 4)], Vector2(size.x / 2, height / 2 + offset + j * height))
	else:
		for row in range(cells):
			draw_symbol(str(rows[row]) if cells == 3 else symbol, Vector2(size.x / 2, height * (row + 0.5)))

func draw_symbol(kind: String, at: Vector2) -> void :
	var scale_factor: = minf(size.x / 36, size.y / (120 if rows.size() == 3 else 40))
	draw_set_transform(at, 0, Vector2.ONE * scale_factor)
	match kind:
		"cherry":
			draw_line(Vector2(-7, 2), Vector2(3, -12), Color("92cb80"), 2, true)
			draw_line(Vector2(7, 5), Vector2(3, -12), Color("92cb80"), 2, true)
			draw_circle(Vector2(-7, 6), 6, Color("ea6a72"))
			draw_circle(Vector2(7, 8), 6, Color("db5664"))
			draw_circle(Vector2(-9, 4), 1.8, Color("ffe3ce"))
			draw_circle(Vector2(5, 6), 1.8, Color("ffe3ce"))
		"bell":
			draw_circle(Vector2(0, 10), 3, Color("f2c575"))
			draw_circle(Vector2(0, -3), 9, Color("f2c575"))
			draw_rect(Rect2(-9, -2, 18, 11), Color("f2c575"))
			draw_line(Vector2(-12, 9), Vector2(12, 9), Color("fff0b6"), 3, true)
			draw_circle(Vector2(0, -13), 2, Color("fff0b6"))
		"star":
			var points: = PackedVector2Array()
			for i in range(10):
				var a: float = - PI / 2 + i * PI / 5
				points.append(Vector2(cos(a), sin(a)) * (13 if i % 2 == 0 else 6))
			draw_colored_polygon(points, Color("99dcd3"))
		"seven":
			draw_polyline(PackedVector2Array([Vector2(-11, -11), Vector2(10, -11), Vector2(-3, 13)]), Color("f18478"), 6, true)
			draw_line(Vector2(-8, 1), Vector2(8, 1), Color("ffe3a9"), 2, true)
	draw_set_transform(Vector2.ZERO)
