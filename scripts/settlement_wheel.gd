extends Control
var rotation_amount: = 0.0
var result_percent: = 1
var finished: = false
var clock: = 0.0
func spin(percent: int) -> void :
	result_percent = percent
	var target: = TAU * 5 + fposmod( - (percent - 0.5) * TAU / 90, TAU)
	var tween: = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "rotation_amount", target, 2.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_callback( func(): finished = true)
func _process(delta: float) -> void :
	clock += delta
	queue_redraw()
func _draw() -> void :
	var center: = size / 2
	var radius: = minf(size.x, size.y) / 2 - 12
	for i in range(90):
		var a: float = - PI / 2 + i * TAU / 90 + rotation_amount
		var b: float = a + TAU / 90
		draw_colored_polygon(PackedVector2Array([center, center + Vector2(cos(a), sin(a)) * radius, center + Vector2(cos(b), sin(b)) * radius]), Color("bd8e3b") if (i / 5) % 2 == 0 else Color("663e77"))
		if (i + 1) % 10 == 0:
			var at: = center + Vector2(cos((a + b) / 2), sin((a + b) / 2)) * radius * 0.78
			draw_string(ThemeDB.fallback_font, at - Vector2(12, -4), "%.2f" % ((i + 1) / 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	draw_circle(center, radius * 0.49, Color("21162f"))
	var shown: = result_percent if finished else int(fmod(clock * 75, 90)) + 1
	draw_string(ThemeDB.fallback_font, center - Vector2(39, -9), "× %.2f" % (shown / 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("ffe6a6"))
	draw_colored_polygon(PackedVector2Array([Vector2(center.x - 10, 4), Vector2(center.x + 10, 4), Vector2(center.x, 23)]), Color("fff2ba"))
