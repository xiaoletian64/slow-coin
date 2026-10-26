extends Node3D


var body_material: StandardMaterial3D
var trim_material: StandardMaterial3D
var steel: StandardMaterial3D
var ink: StandardMaterial3D
var glass: StandardMaterial3D
var warm: StandardMaterial3D
var cool: StandardMaterial3D
var panel: StandardMaterial3D
var _machine: Node3D
var _style_root: Node3D
var _title_label: Label3D
var _subtitle_label: Label3D
var _return_label: Label3D
var current_style: = "classic"

func build(machine: Node3D) -> void :
	_machine = machine
	name = "ArcadeCabinet"
	body_material = _finish(Color("21455d"), 0.46, 0.3)
	trim_material = _finish(Color("d7b67d"), 0.78, 0.25)
	steel = _brushed_steel()
	ink = _finish(Color("09131d"), 0.25, 0.4)
	panel = _finish(Color("12293d"), 0.28, 0.38)
	warm = _finish(Color("ffde9b"), 0.1, 0.28, 0.9)
	cool = _finish(Color("b6e5e8"), 0.15, 0.24, 0.4)
	glass = _finish(Color(0.59, 0.82, 0.89, 0.045), 0.0, 0.09)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.disable_receive_shadows = true
	_build_base()
	_build_playfield()
	_build_backboard()
	_build_enclosure()
	_build_marquee()

func apply_palette(body: Color, trim: Color) -> void :
	body_material.albedo_color = body
	trim_material.albedo_color = trim

func _build_base() -> void :

	_round_box("CabinetBody", Vector3(0, -0.77, -0.25), Vector3(7.3, 1.25, 6.3), 0.22, body_material)
	_round_box("Plinth", Vector3(0, -1.38, 0.28), Vector3(7.16, 0.18, 7.3), 0.075, ink)
	_round_box("LowerReturnFascia", Vector3(0, -1.1, 3.74), Vector3(7.28, 0.5, 0.66), 0.16, body_material)
	_round_box("FasciaInlay", Vector3(0, -1.13, 4.078), Vector3(6.67, 0.24, 0.035), 0.06, panel)
	_round_box("LowerGoldReveal", Vector3(0, -1.38, 3.91), Vector3(6.85, 0.035, 0.14), 0.016, trim_material)
	_round_box("PayoutWell", Vector3(0, -0.88, 3.39), Vector3(6.46, 0.12, 1.27), 0.06, ink)

	_sheet("ReturnRamp", [Vector3(-3.1, -0.28, 2.96), Vector3(3.1, -0.28, 2.96), Vector3(3.1, -0.8, 3.71), Vector3(-3.1, -0.8, 3.71)], _finish(Color("071018"), 0.06, 0.68))
	_round_box("ReturnLip", Vector3(0, -0.81, 3.99), Vector3(6.57, 0.105, 0.22), 0.045, steel)
	_round_box("ReturnLipGold", Vector3(0, -0.748, 3.99), Vector3(6.29, 0.024, 0.1), 0.01, trim_material)
	_round_box("ReturnHood", Vector3(0, -0.27, 3.16), Vector3(6.56, 0.11, 0.32), 0.05, steel)
	_round_box("ReturnUnderglow", Vector3(0, -0.342, 3.26), Vector3(5.75, 0.026, 0.028), 0.012, warm)
	_return_label = _text("C O I N   R E T U R N", Vector3(0, -1.12, 4.102), 29, 0.0064, Color("e7d1a8"))
	for side in [-1.0, 1.0]:
		_round_box("ReturnCheek", Vector3(side * 3.38, -0.55, 3.46), Vector3(0.52, 1.0, 1.22), 0.19, body_material)
		_round_box("CheekCrown", Vector3(side * 3.38, -0.025, 3.43), Vector3(0.53, 0.075, 1.08), 0.035, steel)
		_round_box("CabinetFoot", Vector3(side * 2.87, -1.52, 2.8), Vector3(0.54, 0.14, 0.68), 0.05, ink)

		_disc("ServiceLock", Vector3(side * 2.88, -1.1, 4.075), 0.08, 0.028, steel)
		_round_box("Keyway", Vector3(side * 2.88, -1.1, 4.094), Vector3(0.012, 0.052, 0.008), 0.004, ink)

func _build_playfield() -> void :
	_round_box("BrushedCoinBed", Vector3(0, -0.119, 0.05), Vector3(6.045, 0.222, 5.9), 0.025, steel)
	_round_box("RearTrayWall", Vector3(0, 0.54, -3.08), Vector3(6.8, 1.45, 0.22), 0.07, body_material)
	_round_box("RearTrayCap", Vector3(0, 1.28, -3.06), Vector3(6.8, 0.065, 0.27), 0.03, steel)
	_round_box("StripperFace", Vector3(0, 0.95, -1.89), Vector3(6.0, 0.8, 0.155), 0.04, steel)
	_round_box("StripperReveal", Vector3(0, 1.36, -1.835), Vector3(5.9, 0.025, 0.035), 0.01, trim_material)
	for side in [-1.0, 1.0]:
		_round_box("SculptedSideSill", Vector3(side * 3.44, 0.43, -0.05), Vector3(0.48, 1.41, 6.36), 0.18, body_material)
		_round_box("SideSillCap", Vector3(side * 3.38, 1.155, -0.05), Vector3(0.5, 0.13, 6.38), 0.06, steel)
		_round_box("SideSillGold", Vector3(side * 3.38, 1.225, -0.05), Vector3(0.19, 0.028, 6.19), 0.012, trim_material)
		_round_box("BedSideLight", Vector3(side * 3.128, 0.85, -0.04), Vector3(0.022, 0.046, 5.99), 0.009, warm)
		_round_box("SideLossChannel", Vector3(side * 3.12, -0.24, 1.35), Vector3(0.2, 0.12, 3.6), 0.018, ink)
		_round_box("RearSideShelf", Vector3(side * 3.12, -0.1, -1.7), Vector3(0.2, 0.2, 2.5), 0.022, steel)
		for z in [-2.6, -0.72, 1.15, 2.73]:
			var screw: = _disc("SillScrew", Vector3(side * 3.38, 1.247, z), 0.043, 0.017, steel)
			screw.rotation.x = - PI / 2

		for y in [0.12, 0.31, 0.5]:
			_round_box("SidewallRib", Vector3(side * 3.69, y, 0.1), Vector3(0.035, 0.032, 4.86), 0.012, trim_material)

func _build_backboard() -> void :
	_round_box("RearHousing", Vector3(0, 3.52, -1.93), Vector3(6.79, 4.06, 0.57), 0.25, body_material)
	_round_box("BackboardGoldBezel", Vector3(0, 3.5, -1.617), Vector3(6.27, 3.77, 0.09), 0.16, trim_material)
	_round_box("BackboardInset", Vector3(0, 3.5, -1.56), Vector3(6.08, 3.59, 0.025), 0.12, panel)

	var engraving: = _finish(Color("456477"), 0.62, 0.42)
	for side in [-1.0, 1.0]:
		for i in range(5):
			var a: = Vector3(side * (0.5 + 0.23 * i), 4.38, -1.54)
			var b: = Vector3(side * 2.83, 4.97 - 0.33 * i, -1.54)
			_path("EngravedRay", [a, b], 0.007, engraving, 4)
		_path("BoardEdgeInlay", [Vector3(side * 2.85, 1.96, -1.538), Vector3(side * 2.85, 4.92, -1.538)], 0.012, trim_material, 6)
		_round_box("RearUpright", Vector3(side * 3.17, 3.32, -1.52), Vector3(0.31, 4.3, 0.35), 0.105, steel)
		_round_box("UprightGoldReveal", Vector3(side * 3.17, 3.33, -1.322), Vector3(0.08, 4.1, 0.025), 0.012, trim_material)
		_round_box("RearWarmStrip", Vector3(side * 3.01, 3.37, -1.355), Vector3(0.027, 3.82, 0.029), 0.012, warm)
		for y in [1.5, 5.14]:
			_disc("UprightFastener", Vector3(side * 3.17, y, -1.32), 0.047, 0.025, ink)
	_text("PRECISION  •  COIN  PUSHER", Vector3(0, 1.85, -1.529), 25, 0.0047, Color("a4bbc4"))

	_arc("PivotEscutcheon", Vector3(0, 5.1, -1.526), 0.245, 0.025, trim_material, 0.0, TAU)
	_arc("PivotEtching", Vector3(0, 5.1, -1.528), 0.31, 0.008, engraving, 0.0, TAU)

func _build_enclosure() -> void :
	for side in [-1.0, 1.0]:
		var x: float = side * 3.43

		var rail: Array[Vector3] = [Vector3(x, 1.2, 3.06), Vector3(x, 2.9, 3.06)]
		for i in range(1, 9):
			var t: = float(i) / 8.0
			var p: = _bezier(Vector3(x, 2.9, 3.06), Vector3(x, 3.37, 3.06), Vector3(x, 5.63, -0.73), Vector3(x, 5.63, -1.49), t)
			rail.append(p)
		_path("ContinuousCanopyRail", rail, 0.108, steel, 10)
		var inner: Array[Vector3] = []
		for point in rail:
			inner.append(point + Vector3( - side * 0.01, -0.1, -0.04))
		_path("CanopyGoldReveal", inner, 0.025, trim_material, 6)
		var pane: Array[Vector3] = [Vector3(x, 1.25, -1.4), Vector3(x, 1.25, 2.98)]
		for point in rail:
			if point.y > 1.3: pane.append(point + Vector3(0, -0.11, -0.04))
		_sheet("SafetyGlass", pane, glass)

		_path("GlassGlint", [Vector3(x, 1.54, 2.85), Vector3(x, 2.48, 2.85)], 0.01, cool, 5)
		_path("GlassEdge", [Vector3(x, 1.26, -1.41), Vector3(x, 1.26, 2.98)], 0.018, cool, 6)
		for z in [-1.25, 2.77]:
			_round_box("GlassClamp", Vector3(x, 1.28, z), Vector3(0.16, 0.13, 0.16), 0.03, steel)

	_round_box("OverheadHousing", Vector3(0, 5.52, -1.79), Vector3(6.74, 0.22, 0.85), 0.09, body_material)
	_round_box("OverheadDownlight", Vector3(0, 5.397, -1.53), Vector3(5.97, 0.025, 0.17), 0.012, warm)

func _build_marquee() -> void :
	_round_box("MarqueeHousing", Vector3(0, 5.91, -1.79), Vector3(7.03, 0.84, 0.75), 0.25, body_material)
	_round_box("MarqueeRim", Vector3(0, 5.92, -1.385), Vector3(6.78, 0.66, 0.075), 0.19, trim_material)
	_round_box("MarqueeShadowGap", Vector3(0, 5.92, -1.333), Vector3(6.59, 0.51, 0.045), 0.14, ink)
	_round_box("OpalLightbox", Vector3(0, 5.92, -1.299), Vector3(6.43, 0.4, 0.018), 0.115, warm)
	_title_label = _text("拾 光 币 社", Vector3(-0.17, 5.94, -1.274), 58, 0.0062, Color("172a35"))
	_subtitle_label = _text("A T E L I E R", Vector3(2.12, 5.94, -1.274), 28, 0.006, Color("243b49"))

	_disc("BrandSeal", Vector3(-2.47, 5.94, -1.252), 0.205, 0.052, trim_material)
	_disc("BrandSealInset", Vector3(-2.47, 5.94, -1.214), 0.157, 0.025, panel)
	_star(Vector3(-2.47, 5.94, -1.196), 0.113, trim_material)
	for side in [-1.0, 1.0]:
		for i in range(4):
			_round_box("TopVent", Vector3(side * (2.85 + 0.09 * i), 6.346, -1.77), Vector3(0.029, 0.015, 0.23), 0.007, ink)

func _finish(color: Color, metal: float, roughness: float, emission: float = 0.0) -> StandardMaterial3D:
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metal
	mat.roughness = roughness
	if emission > 0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	return mat

func _brushed_steel() -> StandardMaterial3D:
	var mat: = _finish(Color("acbdc5"), 0.76, 0.37)

	var data: = Image.create(64, 128, false, Image.FORMAT_RGB8)
	for y in range(128):
		for x in range(64):
			var value: = 0.8 + 0.16 * fposmod(sin(float(y) * 78.233 + float(x / 16) * 12.9898) * 43758.5453, 1.0)
			data.set_pixel(x, y, Color(value, value, value))
	data.generate_mipmaps()
	mat.albedo_texture = ImageTexture.create_from_image(data)
	mat.uv1_scale = Vector3(2, 7, 1)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat



func _round_box(label: String, pos: Vector3, size: Vector3, radius: float, mat: Material) -> MeshInstance3D:
	var r: = minf(radius, minf(size.x, size.y) * 0.49)
	var bevel: = minf(r * 0.4, size.z * 0.22)
	var outline: = _rounded_rect(Vector2(size.x, size.y), r)
	var inset: = _rounded_rect(Vector2(size.x, size.y) - Vector2.ONE * bevel * 2.0, maxf(r - bevel, 0.001))
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count: = outline.size()
	for i in range(count):
		var next: = (i + 1) % count
		var n0: = _outline_normal(outline, i)
		var n1: = _outline_normal(outline, next)
		var a: = Vector3(outline[i].x, outline[i].y, - size.z / 2 + bevel)
		var b: = Vector3(outline[next].x, outline[next].y, - size.z / 2 + bevel)
		var c: = Vector3(outline[next].x, outline[next].y, size.z / 2 - bevel)
		var d: = Vector3(outline[i].x, outline[i].y, size.z / 2 - bevel)
		_quad(st, a, b, c, d, n0, n1, n1, n0)
		for side in [-1.0, 1.0]:
			var p0: = Vector3(inset[i].x, inset[i].y, side * size.z / 2)
			var p1: = Vector3(inset[next].x, inset[next].y, side * size.z / 2)
			var p2: = Vector3(outline[next].x, outline[next].y, side * (size.z / 2 - bevel))
			var p3: = Vector3(outline[i].x, outline[i].y, side * (size.z / 2 - bevel))
			var cap_normal: = Vector3(0, 0, side)
			_triangle(st, Vector3(0, 0, side * size.z / 2), p0, p1, cap_normal, cap_normal, cap_normal)
			_quad(st, p0, p1, p2, p3, (n0 + cap_normal).normalized(), (n1 + cap_normal).normalized(), (n1 + cap_normal).normalized(), (n0 + cap_normal).normalized())
	return _mesh(label, st.commit(), pos, mat)

func _rounded_rect(size: Vector2, radius: float) -> PackedVector2Array:
	var points: = PackedVector2Array()
	for corner in range(4):
		var angle: = float(corner) * PI / 2.0
		var center: = Vector2(1.0 if corner == 0 or corner == 3 else -1.0, 1.0 if corner < 2 else -1.0) * (size / 2 - Vector2.ONE * radius)
		for step in range(7):
			var a: = angle + float(step) / 6.0 * PI / 2.0
			points.append(center + Vector2(cos(a), sin(a)) * radius)
	return points

func _outline_normal(points: PackedVector2Array, index: int) -> Vector3:
	var before: = points[index] - points[(index - 1 + points.size()) % points.size()]
	var after: = points[(index + 1) % points.size()] - points[index]
	var tangent: = before.normalized() + after.normalized()
	return Vector3(tangent.y, - tangent.x, 0).normalized()

func _mesh(label: String, shape: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mesh: = MeshInstance3D.new()
	mesh.name = label
	mesh.mesh = shape
	mesh.position = pos
	mesh.material_override = mat
	add_child(mesh, true)
	return mesh

func _triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, na: Vector3, nb: Vector3, nc: Vector3) -> void :
	var vertices: Array[Vector3] = [a, b, c]
	var normals: Array[Vector3] = [na, nb, nc]
	if (b - a).cross(c - a).dot(na + nb + nc) > 0:
		vertices = [a, c, b]
		normals = [na, nc, nb]
	for i in range(3):
		st.set_normal(normals[i])
		st.set_uv(Vector2(vertices[i].x + vertices[i].z, vertices[i].y + vertices[i].z))
		st.add_vertex(vertices[i])

func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, na: Vector3, nb: Vector3, nc: Vector3, nd: Vector3) -> void :
	_triangle(st, a, b, c, na, nb, nc)
	_triangle(st, a, c, d, na, nc, nd)

func _sheet(label: String, points: Array[Vector3], mat: Material) -> void :
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var normal: = (points[1] - points[0]).cross(points[2] - points[0]).normalized()
	if normal.y < -0.1:
		normal = - normal
	for i in range(1, points.size() - 1):
		_triangle(st, points[0], points[i], points[i + 1], normal, normal, normal)
	var mesh: = _mesh(label, st.commit(), Vector3.ZERO, mat)
	if mat == glass: mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _path(label: String, points: Array[Vector3], radius: float, mat: Material, sides: int = 8) -> void :
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array = []
	var is_xy: = true
	for point in points:
		if absf(point.z - points[0].z) > 0.001: is_xy = false
	for i in range(points.size()):

		var tangent: = (points[mini(i + 1, points.size() - 1)] - points[maxi(i - 1, 0)]).normalized()
		var reference: = Vector3.BACK if is_xy else Vector3.RIGHT
		if absf(tangent.dot(reference)) > 0.98: reference = Vector3.UP
		var u: = tangent.cross(reference).normalized()
		var v: = tangent.cross(u).normalized()
		var ring: Array[Vector3] = []
		for j in range(sides):
			ring.append(u * cos(float(j) * TAU / sides) + v * sin(float(j) * TAU / sides))
		rings.append(ring)
	for i in range(points.size() - 1):
		for j in range(sides):
			var next: = (j + 1) % sides
			var a: Vector3 = rings[i][j]
			var b: Vector3 = rings[i][next]
			var c: Vector3 = rings[i + 1][next]
			var d: Vector3 = rings[i + 1][j]
			_quad(st, points[i] + a * radius, points[i] + b * radius, points[i + 1] + c * radius, points[i + 1] + d * radius, a, b, c, d)
	for end in [0, points.size() - 1]:
		var normal: = (points[0] - points[1]).normalized() if end == 0 else (points[end] - points[end - 1]).normalized()
		for j in range(sides):
			_triangle(st, points[end], points[end] + rings[end][j] * radius, points[end] + rings[end][(j + 1) % sides] * radius, normal, normal, normal)
	_mesh(label, st.commit(), Vector3.ZERO, mat)

func _arc(label: String, pos: Vector3, radius: float, section: float, mat: Material, start: float, end: float) -> void :
	var points: Array[Vector3] = []
	for i in range(49):
		var angle: = lerpf(start, end, float(i) / 48.0)
		points.append(pos + Vector3(cos(angle) * radius, sin(angle) * radius, 0))
	_path(label, points, section, mat, 6)

func _disc(label: String, pos: Vector3, radius: float, depth: float, mat: Material) -> MeshInstance3D:
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(32):
		var a: = float(i) * TAU / 32.0
		var b: = float(i + 1) * TAU / 32.0
		var na: = Vector3(cos(a), sin(a), 0)
		var nb: = Vector3(cos(b), sin(b), 0)
		_quad(st, na * radius - Vector3(0, 0, depth / 2), nb * radius - Vector3(0, 0, depth / 2), nb * radius + Vector3(0, 0, depth / 2), na * radius + Vector3(0, 0, depth / 2), na, nb, nb, na)
		for side in [-1.0, 1.0]:
			var n: = Vector3(0, 0, side)
			_triangle(st, n * depth / 2, na * radius + n * depth / 2, nb * radius + n * depth / 2, n, n, n)
	return _mesh(label, st.commit(), pos, mat)

func _star(pos: Vector3, radius: float, mat: Material) -> void :
	var points: Array[Vector3] = []
	for i in range(10):
		var a: = PI / 2 + float(i) * TAU / 10.0
		var r: = radius if i % 2 == 0 else radius * 0.43
		points.append(pos + Vector3(cos(a) * r, sin(a) * r, 0))
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(10):
		_triangle(st, pos, points[i], points[(i + 1) % 10], Vector3.BACK, Vector3.BACK, Vector3.BACK)
	_mesh("StampedStar", st.commit(), Vector3.ZERO, mat)

func _text(words: String, pos: Vector3, size: int, pixel: float, color: Color) -> Label3D:
	var label: = Label3D.new()
	label.name = "CabinetLettering"
	label.text = words
	var font: = FontVariation.new()
	font.base_font = load("res://assets/fonts/NotoSansSC.ttf")
	font.variation_opentype = {2003265652: 700.0}
	label.font = font
	label.font_size = size
	label.pixel_size = pixel
	label.position = pos
	label.modulate = color
	label.outline_size = 0
	label.no_depth_test = false
	add_child(label)
	return label

func _bezier(a: Vector3, b: Vector3, c: Vector3, d: Vector3, t: float) -> Vector3:
	var s: = 1.0 - t
	return s * s * s * a + 3.0 * s * s * t * b + 3.0 * s * t * t * c + t * t * t * d



func set_style(id: String) -> void :
	var target_style: = id if id in ["retro", "future", "royal", "aurora"] else "classic"
	if _style_root != null and current_style == target_style:
		return
	if _style_root != null:
		remove_child(_style_root)
		_style_root.queue_free()
		_style_root = null
	current_style = target_style
	var colors: = {
		"classic": ["21455d", "d7b67d", "12293d", "ffde9b"],
		"retro": ["623b34", "ddb574", "2c2525", "ffca7e"],
		"future": ["17253f", "79cde8", "111c37", "81e4ff"],
		"royal": ["383542", "edc775", "211d2c", "ffdf93"],
		"aurora": ["315b67", "c5f4ec", "183944", "baf9df"]
	}
	var palette: Array = colors[current_style]
	apply_palette(Color(palette[0]), Color(palette[1]))
	panel.albedo_color = Color(palette[2])
	warm.albedo_color = Color(palette[3])
	warm.emission = Color(palette[3])
	_title_label.text = {"classic": "拾 光 币 社", "retro": "落 日 街 机", "future": "量 子 推 币", "royal": "鎏 金 典 藏", "aurora": "极 光 冰 宫"}[current_style]
	_subtitle_label.text = {"classic": "A T E L I E R", "retro": "R E T R O", "future": "Q U A N T U M", "royal": "R O Y A L", "aurora": "A U R O R A"}[current_style]
	var first: = get_child_count()
	match current_style:
		"retro": _style_retro()
		"future": _style_future()
		"royal": _style_royal()
		"aurora": _style_aurora()
	var additions: = get_children().slice(first)
	_style_root = Node3D.new()
	_style_root.name = "StyleDetails_" + current_style
	add_child(_style_root)
	for child in additions:
		child.reparent(_style_root, false)
	_return_label.visible = true
	if current_style != "classic":
		_attach_blender_metalwork()

func _attach_blender_metalwork() -> void :
	var path: = "res://assets/models/cabinet_%s.glb" % current_style
	if not ResourceLoader.exists(path):
		return
	var scene: = load(path) as PackedScene
	if scene == null:
		return
	var metalwork: = scene.instantiate() as Node3D
	metalwork.name = "BlenderMetalwork"
	_style_root.add_child(metalwork)


	_return_label.visible = false
	for child in _style_root.get_children():
		if str(child.name).begins_with("QuantumReturnSegment") or str(child.name).begins_with("AuroraLowerInlay"):
			child.visible = false

func _style_retro() -> void :

	var crest: Array[Vector2] = [Vector2(-3.17, 6.2), Vector2(3.17, 6.2)]
	for i in range(17):
		var x: = 3.17 - float(i) * 6.34 / 16.0
		crest.append(Vector2(x, 6.3 + 0.34 * sin(float(i) * PI / 16.0)))
	_profile("RetroRolledCrest", crest, -1.66, 0.23, body_material)
	var arch: Array[Vector3] = []
	for i in range(25):
		var x: = -3.1 + float(i) * 6.2 / 24.0
		arch.append(Vector3(x, 6.31 + 0.31 * sin(float(i) * PI / 24.0), -1.505))
	_path("RetroCrestGoldRoll", arch, 0.028, trim_material, 8)
	for i in range(17):
		var t: = float(i) / 16.0
		var pos: = Vector3(-2.99 + t * 5.98, 6.3 + 0.265 * sin(t * PI), -1.468)
		_disc("RetroLampSocket", pos, 0.055, 0.037, ink)
		_disc("RetroWarmBulb", pos + Vector3(0, 0, 0.028), 0.037, 0.033, warm)
	for side in [-1.0, 1.0]:
		_disc("RetroSideMedallion", Vector3(side * 3.17, 4.95, -1.284), 0.145, 0.035, trim_material)
		_disc("RetroSideMedallionEnamel", Vector3(side * 3.17, 4.95, -1.259), 0.105, 0.024, body_material)
		_star(Vector3(side * 3.17, 4.95, -1.241), 0.074, warm)
		for y in [3.1, 3.33, 3.56, 3.79]:
			_disc("RetroUprightLamp", Vector3(side * 3.17, y, -1.285), 0.032, 0.025, warm)

func _style_future() -> void :
	var alloy: = _finish(Color("374563"), 0.72, 0.25)
	var hologram: = _finish(Color("67dff7"), 0.38, 0.2, 1.1)
	var purple: = _finish(Color("9d9eff"), 0.36, 0.25, 0.8)

	for side in [-1.0, 1.0]:
		var points: Array[Vector2] = [Vector2(side * 0.35, 6.28), Vector2(side * 0.65, 6.57), Vector2(side * 2.86, 6.57), Vector2(side * 3.43, 6.17), Vector2(side * 3.18, 6.17), Vector2(side * 2.7, 6.36), Vector2(side * 0.78, 6.36)]
		_profile("QuantumFloatingVisor", points, -1.69, 0.28, alloy)
		_path("QuantumVisorLight", [Vector3(side * 0.68, 6.59, -1.53), Vector3(side * 2.85, 6.59, -1.53), Vector3(side * 3.35, 6.24, -1.53)], 0.024, hologram, 6)
		for i in range(3):
			var y: = 4.55 + float(i) * 0.2
			_profile("QuantumSideFin", [Vector2(side * 3.05, y), Vector2(side * 3.44, y + 0.15), Vector2(side * 3.44, y + 0.21), Vector2(side * 3.05, y + 0.06)], -1.33, 0.16, alloy)
			_path("QuantumFinLight", [Vector3(side * 3.07, y + 0.08, -1.232), Vector3(side * 3.41, y + 0.22, -1.232)], 0.015, hologram, 5)
		_path("QuantumBedTrace", [Vector3(side * 3.39, 1.252, -0.4), Vector3(side * 3.39, 1.252, 2.6)], 0.021, purple, 6)

	_path("QuantumDiamond", [Vector3(0, 6.27, -1.53), Vector3(-0.22, 6.49, -1.53), Vector3(0, 6.71, -1.53), Vector3(0.22, 6.49, -1.53), Vector3(0, 6.27, -1.53)], 0.027, hologram, 6)
	for i in range(7):
		_round_box("QuantumReturnSegment", Vector3(-0.66 + float(i) * 0.22, -1.13, 4.112), Vector3(0.12, 0.037, 0.024), 0.012, hologram)

func _style_royal() -> void :
	var gold: = _finish(Color("eac579"), 0.86, 0.23)
	var enamel: = _finish(Color("392c42"), 0.38, 0.25)
	var crown: Array[Vector2] = [Vector2(-2.91, 6.24), Vector2(-2.91, 6.42), Vector2(-2.42, 6.42), Vector2(-2.42, 6.54), Vector2(-1.55, 6.54), Vector2(-1.55, 6.65), Vector2(-0.45, 6.65), Vector2(0, 6.8), Vector2(0.45, 6.65), Vector2(1.55, 6.65), Vector2(1.55, 6.54), Vector2(2.42, 6.54), Vector2(2.42, 6.42), Vector2(2.91, 6.42), Vector2(2.91, 6.24)]
	_profile("RoyalSteppedCrown", crown, -1.62, 0.26, gold)
	_round_box("RoyalCrownEnamel", Vector3(0, 6.4, -1.464), Vector3(5.46, 0.2, 0.025), 0.04, enamel)
	for i in range(11):
		var x: = -2.42 + float(i) * 0.484
		_round_box("RoyalCrownFlute", Vector3(x, 6.49, -1.438), Vector3(0.026, 0.2 + 0.11 * (1.0 - absf(x) / 2.42), 0.028), 0.01, gold)
	_disc("RoyalCoinCrest", Vector3(0, 6.48, -1.391), 0.235, 0.09, gold)
	_disc("RoyalCoinEnamel", Vector3(0, 6.48, -1.327), 0.172, 0.035, enamel)
	_star(Vector3(0, 6.48, -1.306), 0.124, gold)
	for side in [-1.0, 1.0]:
		for y in [1.63, 4.76]:
			_round_box("RoyalColumnCapital", Vector3(side * 3.18, y, -1.303), Vector3(0.43, 0.19, 0.1), 0.06, gold)
		for i in range(7):
			_disc("RoyalColumnStud", Vector3(side * 3.17, 2.07 + float(i) * 0.34, -1.291), 0.025, 0.027, gold)
		for xoff in [-0.065, 0.065]:
			_path("RoyalColumnFlute", [Vector3(side * 3.17 + xoff, 1.87, -1.29), Vector3(side * 3.17 + xoff, 4.48, -1.29)], 0.014, gold, 5)
		_round_box("RoyalReturnCorner", Vector3(side * 3.39, -0.5, 4.045), Vector3(0.26, 0.43, 0.038), 0.07, gold)

func _style_aurora() -> void :
	var frost: = _finish(Color("bedde6"), 0.52, 0.21)
	var teal: = _finish(Color("88e1d4"), 0.48, 0.22)
	var lavender: = _finish(Color("acaee3"), 0.44, 0.23)
	var edge: = _finish(Color("b0ffe5"), 0.18, 0.22, 0.8)


	for side in [-1.0, 1.0]:
		_crystal("AuroraTallCrystal", Vector3(side * 2.73, 6.12, -1.58), 0.155, 0.64, frost)
		_crystal("AuroraTealCrystal", Vector3(side * 3.01, 6.11, -1.58), 0.145, 0.43, teal)
		_crystal("AuroraLilacCrystal", Vector3(side * 2.43, 6.14, -1.58), 0.135, 0.38, lavender)
		_crystal("AuroraColumnGem", Vector3(side * 3.18, 4.48, -1.232), 0.112, 0.39, frost)
		_path("AuroraColumnLight", [Vector3(side * 3.18, 1.82, -1.26), Vector3(side * 3.18, 4.36, -1.26)], 0.023, edge, 6)
	var ribbon: Array[Vector3] = []
	var ribbon2: Array[Vector3] = []
	for i in range(33):
		var t: = float(i) / 32.0
		var x: = -2.28 + t * 4.56
		ribbon.append(Vector3(x, 6.38 + 0.085 * sin(t * TAU), -1.46))
		ribbon2.append(Vector3(x, 6.46 + 0.085 * sin(t * TAU + 0.5), -1.48))
	_path("AuroraRibbon", ribbon, 0.036, teal, 8)
	_path("AuroraRibbonLight", ribbon2, 0.021, edge, 6)
	for side in [-1.0, 1.0]:
		_path("AuroraLowerInlay", [Vector3(side * 0.16, -1.13, 4.11), Vector3(side * 0.39, -0.997, 4.11), Vector3(side * 0.62, -1.13, 4.11)], 0.02, lavender, 6)


func _profile(label: String, outline: Array[Vector2], z: float, depth: float, mat: Material) -> void :
	var polygon: = PackedVector2Array(outline)
	var indices: = Geometry2D.triangulate_polygon(polygon)
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1.0, 1.0]:
		var normal: = Vector3(0, 0, side)
		for i in range(0, indices.size(), 3):
			var a: = outline[indices[i]]
			var b: = outline[indices[i + 1]]
			var c: = outline[indices[i + 2]]
			_triangle(st, Vector3(a.x, a.y, z + side * depth / 2), Vector3(b.x, b.y, z + side * depth / 2), Vector3(c.x, c.y, z + side * depth / 2), normal, normal, normal)
	var clockwise: = Geometry2D.is_polygon_clockwise(polygon)
	for i in range(outline.size()):
		var a: = outline[i]
		var b: = outline[(i + 1) % outline.size()]
		var edge: = b - a
		var normal: = Vector3(edge.y, - edge.x, 0).normalized()
		if clockwise: normal = - normal
		_quad(st, Vector3(a.x, a.y, z - depth / 2), Vector3(b.x, b.y, z - depth / 2), Vector3(b.x, b.y, z + depth / 2), Vector3(a.x, a.y, z + depth / 2), normal, normal, normal, normal)
	_mesh(label, st.commit(), Vector3.ZERO, mat)

func _crystal(label: String, pos: Vector3, radius: float, height: float, mat: Material) -> void :
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tip: = Vector3(radius * 0.22, height, 0)
	for i in range(6):
		var a: = float(i) * TAU / 6.0
		var b: = float(i + 1) * TAU / 6.0
		var p: = Vector3(cos(a) * radius, 0, sin(a) * radius)
		var q: = Vector3(cos(b) * radius, 0, sin(b) * radius)
		var top_p: = p + Vector3(0, height * 0.6, 0)
		var top_q: = q + Vector3(0, height * 0.6, 0)
		var normal: = Vector3(cos((a + b) / 2), 0, sin((a + b) / 2))
		_quad(st, p, q, top_q, top_p, normal, normal, normal, normal)
		var tip_normal: = (top_q - top_p).cross(tip - top_p).normalized()
		if tip_normal.y < 0: tip_normal = - tip_normal
		_triangle(st, top_p, top_q, tip, tip_normal, tip_normal, tip_normal)
		_triangle(st, Vector3.ZERO, q, p, Vector3.DOWN, Vector3.DOWN, Vector3.DOWN)
	_mesh(label, st.commit(), pos, mat)
