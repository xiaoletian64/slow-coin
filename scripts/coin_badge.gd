extends Control
var tint: = Color("f0c577")
var locked: = false
func _draw() -> void :
	var c: = size / 2.0
	var r: = minf(size.x, size.y) * 0.41
	var base: = Color("344957") if locked else tint
	draw_circle(c + Vector2(0, 3), r, base.darkened(0.55))
	draw_circle(c, r, base)
	draw_arc(c, r * 0.77, 0, TAU, 48, base.lightened(0.36), 1.5, true)
	var points: = PackedVector2Array()
	for i in range(10):
		var a: = - PI / 2 + i * PI / 5
		points.append(c + Vector2(cos(a), sin(a)) * r * (0.46 if i % 2 == 0 else 0.21))
	draw_colored_polygon(points, base.darkened(0.38))
