extends Control

const I18n = preload("res://scripts/i18n.gd")
const DURATION: = 3.4
var clock: = 0.0
var amount: = 0
var caption: Label
var reward_label: Label
var unit_label: Label
var payout_hint: Label
var panel_center: = Vector2.ZERO
var scene_scale: = 1.0
var _font: FontVariation
var _tier: = 0
var _accent: = Color("e5c78b")
var _secondary: = Color("92c5c9")

func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_font = FontVariation.new()
	_font.base_font = load("res://assets/fonts/NotoSansSC.ttf")
	_font.variation_opentype = {2003265652: 650.0}
	caption = _label(19, Color("e8d6ac"))
	reward_label = _label(72, Color("fff0c5"))
	unit_label = _label(13, Color("b8cad1"))
	payout_hint = _label(12, Color("92a9b8"))
	resized.connect(_resize_presentation)
	visible = clock > 0.0
	if visible: update_layout()

func _label(font_size: int, color: Color) -> Label:
	var node: = Label.new()
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_font_override("font", _font)
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.add_theme_color_override("font_shadow_color", Color(0.01, 0.025, 0.04, 0.7))
	node.add_theme_constant_override("shadow_offset_y", 2)
	add_child(node)
	return node

func celebrate(prize: int, remaining: = DURATION) -> void :
	sync_state(prize, remaining)

func sync_state(prize: int, remaining: float) -> void :
	amount = maxi(0, prize)
	clock = clampf(remaining, 0.0, DURATION)
	visible = clock > 0.0 and amount > 0
	_tier = 3 if amount >= 10000 else (2 if amount >= 2888 else (1 if amount >= 388 else 0))
	_accent = [Color("e5c78b"), Color("edc96e"), Color("f2d18d"), Color("eee0b8")][_tier]
	_secondary = [Color("92c5c9"), Color("93d9ce"), Color("78cbd2"), Color("a1bfe4")][_tier]
	if visible and caption != null: update_layout()
	queue_redraw()

func _resize_presentation() -> void :
	if caption != null: update_layout()
	queue_redraw()

func update_layout() -> void :
	scene_scale = clampf((size.x - 24.0) / 392.0, 0.45, 1.0)
	panel_center = Vector2(size.x / 2.0, size.y * 0.475)
	var age: = DURATION - clock
	var arrival: = _ease_out(clampf(age / 0.5, 0, 1))
	var fade: = smoothstep(0.0, 0.24, age) * (1.0 - smoothstep(2.94, DURATION, age))
	var reveal: = smoothstep(0.56, 0.91, age)
	var lift: = 12.0 * (1.0 - arrival) * scene_scale
	caption.text = I18n.jackpot_caption(_tier)
	reward_label.text = _format_amount(amount)
	unit_label.text = I18n.jackpot_unit()
	payout_hint.text = I18n.jackpot_payout_hint()
	_place_label(caption, -141.0, 36.0, 19, fade, lift)
	_place_label(reward_label, 14.0, 92.0, 72 if amount < 10000 else 65, fade * reveal, lift)
	_place_label(unit_label, 118.0, 26.0, 13, fade * reveal, lift)
	_place_label(payout_hint, 160.0, 24.0, 12, fade * smoothstep(0.88, 1.28, age), lift)

func _place_label(node: Label, offset_y: float, height: float, font_size: int, alpha: float, lift: float) -> void :
	node.position = Vector2(panel_center.x - 192.0 * scene_scale, panel_center.y + offset_y * scene_scale + lift)
	node.size = Vector2(384.0, height) * scene_scale
	node.add_theme_font_size_override("font_size", maxi(8, roundi(font_size * scene_scale)))
	node.modulate.a = alpha

static func _format_amount(value: int) -> String:
	var digits: = str(value)
	var result: = ""
	for i in range(digits.length()):
		if i > 0 and (digits.length() - i) % 3 == 0: result += ","
		result += digits[i]
	return result

func _draw() -> void :
	if clock <= 0 or amount <= 0: return
	var age: = DURATION - clock
	var arrival: = _ease_out(clampf(age / 0.5, 0, 1))
	var fade: = smoothstep(0.0, 0.24, age) * (1.0 - smoothstep(2.94, DURATION, age))
	var reveal: = smoothstep(0.55, 1.02, age)

	draw_rect(Rect2(Vector2.ZERO, size), Color(0.012, 0.022, 0.037, 0.24 * fade))
	draw_set_transform(panel_center + Vector2(0, 12.0 * (1.0 - arrival) * scene_scale), 0, Vector2.ONE * scene_scale)
	_draw_glass_card(fade)
	var origin: = Vector2(0, -43)

	for i in range(9, 0, -1):
		var tint: = _secondary
		tint.a = (0.005 + 0.0012 * _tier) * fade * reveal
		draw_circle(origin, 47.0 + i * 7.0, tint)
	if _tier >= 2: _draw_light_fan(origin, age, fade * reveal)
	_draw_dial(origin, age, fade, reveal)
	_draw_coin_arcs(origin, age, fade)
	var coin_scale: = lerpf(0.28, 1.0, _ease_out(clampf((age - 0.12) / 0.72, 0, 1)))
	var coin_squash: = lerpf(0.1, 1.0, smoothstep(0.16, 0.73, age))
	_draw_coin(origin, 37.0 * coin_scale, coin_squash, fade, age * 0.5, true)
	_draw_sparks(origin, age, fade)

	var line_color: = _accent
	line_color.a = fade * 0.28
	draw_line(Vector2(-122, 151), Vector2(122, 151), line_color, 1, true)
	var progress: = clampf(age / DURATION, 0, 1)
	var track: = _secondary
	track.a = 0.7 * fade
	draw_line(Vector2(-35, 191), Vector2(-35 + 70 * progress, 191), track, 1.5, true)
	draw_set_transform(Vector2.ZERO)

func _draw_glass_card(alpha: float) -> void :
	var rect: = Rect2(-196, -165, 392, 372)

	for i in range(4, 0, -1):
		var shadow: = StyleBoxFlat.new()
		shadow.bg_color = Color(0.0, 0.005, 0.015, 0.035 * alpha)
		shadow.set_corner_radius_all(22 + i * 2)
		var shadow_rect: = rect.grow(float(i) * 3.0)
		shadow_rect.position.y += 5.0
		draw_style_box(shadow, shadow_rect)
	var outer: = StyleBoxFlat.new()
	outer.bg_color = Color(0.035, 0.067, 0.098, 0.96 * alpha)
	outer.border_color = Color(_accent, 0.66 * alpha)
	outer.set_border_width_all(1)
	outer.set_corner_radius_all(20)
	draw_style_box(outer, rect)
	var inset: = StyleBoxFlat.new()
	inset.bg_color = Color(0.06, 0.11, 0.15, 0.4 * alpha)
	inset.border_color = Color(0.58, 0.75, 0.79, 0.16 * alpha)
	inset.set_border_width_all(1)
	inset.set_corner_radius_all(16)
	draw_style_box(inset, rect.grow(-6))

	draw_polygon(PackedVector2Array([Vector2(-181, -144), Vector2(-74, -158), Vector2(137, -158), Vector2(-181, -59)]), PackedColorArray([Color(0.58, 0.78, 0.83, 0.012 * alpha), Color(0.58, 0.78, 0.83, 0.035 * alpha), Color(0.58, 0.78, 0.83, 0.0), Color(0.58, 0.78, 0.83, 0.0)]))
	for side in [-1, 1]:
		var color: = Color(_accent, 0.58 * alpha)
		draw_line(Vector2(side * 169, -133), Vector2(side * 169, -102), color, 1, true)
		draw_line(Vector2(side * 169, -133), Vector2(side * 146, -133), color, 1, true)
		draw_circle(Vector2(side * 170, 181), 1.4, Color(_accent, 0.5 * alpha))

func _draw_dial(origin: Vector2, age: float, alpha: float, reveal: float) -> void :
	var charge: = smoothstep(0.08, 0.89, age)
	var radius: = 52.0 + sin(age * 1.6) * 1.2
	draw_arc(origin, radius, 0, TAU, 80, Color(_accent, 0.22 * alpha), 1, true)
	draw_arc(origin, radius, - PI / 2, - PI / 2 + TAU * maxf(0.001, charge), 80, Color(_accent, 0.83 * alpha), 1.5, true)
	for i in range(32):
		var a: = float(i) * TAU / 32.0 - PI / 2
		var direction: = Vector2(cos(a), sin(a))
		var lit: = float(i) / 32.0 <= charge
		var color: = Color(_accent, (0.65 if lit else 0.12) * alpha)
		draw_line(origin + direction * 59, origin + direction * (63 if i % 4 == 0 else 61), color, 1, true)
	if _tier >= 1:
		for side in [-1, 1]:
			var a: = float(side) * PI / 2 + age * 0.28
			draw_arc(origin, 70, a, a + 1.02, 24, Color(_secondary, 0.64 * alpha * reveal), 1.4, true)
	if _tier >= 2:
		for i in range(4):
			var a: = float(i) * PI / 2 - age * 0.15
			draw_arc(origin, 79, a, a + 0.62, 18, Color(_accent, 0.39 * alpha * reveal), 1, true)
	if _tier == 3:
		for side in [-1, 1]:

			for i in range(4):
				var x: = 94.0 + float(i) * 10.0
				var h: = 22.0 - float(i) * 4.0
				draw_line(origin + Vector2(side * x, - h), origin + Vector2(side * x, h), Color(_accent, (0.7 - i * 0.12) * alpha * reveal), 2, true)

func _draw_light_fan(origin: Vector2, age: float, alpha: float) -> void :
	var flare: = smoothstep(0.61, 0.89, age) * (1.0 - smoothstep(1.08, 1.7, age))
	var count: = 8 if _tier == 2 else 12
	for i in range(count):
		var angle: = float(i) * TAU / count + age * 0.035
		var reach: = 119.0 if i % 2 == 0 else 94.0
		var half_width: = 0.035 if _tier == 2 else 0.055
		var vertices: = PackedVector2Array([origin + Vector2(cos(angle - half_width), sin(angle - half_width)) * 45, origin + Vector2(cos(angle - half_width), sin(angle - half_width)) * reach, origin + Vector2(cos(angle + half_width), sin(angle + half_width)) * reach, origin + Vector2(cos(angle + half_width), sin(angle + half_width)) * 45])
		var bright: = Color(_accent, alpha * (0.025 + flare * 0.12))
		var clear: = Color(_accent, 0)
		draw_polygon(vertices, PackedColorArray([bright, clear, clear, bright]))

	var burst: = clampf((age - 0.69) / 0.83, 0, 1)
	if burst > 0 and burst < 1:
		draw_arc(origin, 42 + burst * 87, 0, TAU, 100, Color(_accent, (1 - burst) * 0.45 * alpha), 1.3, true)

func _draw_coin_arcs(origin: Vector2, age: float, alpha: float) -> void :
	var count: int = [4, 8, 12, 18][_tier]
	for i in range(count):
		var delay: = float(i % 6) * 0.055
		var t: = (age - 0.8 - delay) / 1.85
		if t <= 0 or t >= 1: continue
		var side: = -1.0 if i % 2 == 0 else 1.0
		var lane: = float(i / 2) / maxf(1.0, float(count / 2 - 1))
		var velocity: = Vector2(side * (82 + lane * 67), -110 - lane * 94)
		var at: = origin + velocity * t + Vector2(0, 175 * t * t)
		var visibility: = smoothstep(0, 0.1, t) * (1 - smoothstep(0.6, 1.0, t)) * alpha
		var squash: = 0.26 + absf(cos(t * 8.0 + float(i) * 0.71)) * 0.74
		_draw_coin(at, 5.0 + float(i % 3) * 1.0, squash, visibility, t * 6 + float(i), false)

func _draw_sparks(origin: Vector2, age: float, alpha: float) -> void :
	var t: = age - 0.73
	if t <= 0: return
	var count: int = [6, 10, 14, 20][_tier]
	for i in range(count):
		var a: = float(i) * 2.399963
		var pace: = 13.0 + float(i % 5) * 4.2
		var at: = origin + Vector2(cos(a), sin(a)) * (66.0 + t * pace) + Vector2(0, t * t * 5.5)
		var fade: = (1.0 - smoothstep(0.8, 2.35, t)) * smoothstep(0, 0.18, t) * alpha
		var pulse: = 0.48 + 0.52 * absf(sin(t * 2.8 + float(i)))
		var color: = Color(_secondary if i % 3 == 0 else _accent, fade * pulse * 0.72)
		var radius: = 1.2 if i % 3 else 2.4
		draw_line(at - Vector2(radius, 0), at + Vector2(radius, 0), color, 1, true)
		if i % 3 == 0: draw_line(at - Vector2(0, radius), at + Vector2(0, radius), color, 1, true)

func _draw_coin(at: Vector2, radius: float, squash: float, alpha: float, turn: float, hero: bool) -> void :
	var rim: = Color("9c793e")
	var face: = Color("e9c97f")
	var highlight: = Color("fff0bb")
	var shade: = Color("846138")
	rim.a = alpha
	face.a = alpha
	highlight.a = alpha
	shade.a = alpha
	_oval(at + Vector2(0, radius * 0.11), Vector2(radius * squash, radius), Color(0.01, 0.02, 0.03, 0.35 * alpha))
	_oval(at + Vector2(radius * 0.025, radius * 0.035), Vector2(radius * squash, radius), rim)
	_oval(at - Vector2(0, radius * 0.035), Vector2(radius * 0.93 * squash, radius * 0.93), face)
	var ring: = PackedVector2Array()
	for i in range(49):
		var a: = float(i) * TAU / 48
		ring.append(at + Vector2(cos(a) * squash, sin(a)) * radius * 0.79)
	draw_polyline(ring, Color(shade, 0.68 * alpha), 1.0 if hero else 0.65, true)
	if hero:
		for i in range(36):
			var a: = float(i) * TAU / 36
			var direction: = Vector2(cos(a) * squash, sin(a))
			draw_line(at + direction * radius * 0.85, at + direction * radius * 0.91, Color(shade, 0.61 * alpha), 1, true)
		var sheen: = PackedVector2Array()
		for i in range(25):
			var a: = PI + float(i) * PI / 24
			sheen.append(at + Vector2(cos(a) * squash, sin(a)) * radius * 0.95)
		draw_polyline(sheen, Color(highlight, 0.83 * alpha), 1.5, true)
	var star: = PackedVector2Array()
	for i in range(10):
		var a: = - PI / 2 + float(i) * PI / 5 + (0.02 * sin(turn) if hero else 0.0)
		var distance: = radius * (0.49 if i % 2 == 0 else 0.23)
		star.append(at + Vector2(cos(a) * squash, sin(a)) * distance)
	draw_colored_polygon(star, shade)
	if hero:
		var inset_star: = PackedVector2Array()
		for point in star: inset_star.append(at + (point - at) * 0.88 - Vector2(0, 0.8))
		draw_colored_polygon(inset_star, Color("c49c56") * Color(1, 1, 1, alpha))

func _oval(at: Vector2, radius: Vector2, color: Color) -> void :
	var points: = PackedVector2Array()
	for i in range(48):
		var a: = float(i) * TAU / 48
		points.append(at + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_colored_polygon(points, color)

func screen_shake() -> Vector2:
	if clock <= 0 or amount < 2888: return Vector2.ZERO
	var age: = DURATION - clock
	var impact: = smoothstep(0.66, 0.84, age) * (1.0 - smoothstep(0.94, 1.28, age))
	var amplitude: = 1.25 if amount < 10000 else 2.0
	return Vector2(sin(age * 57), cos(age * 71) * 0.65) * amplitude * impact

func _ease_out(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3)
