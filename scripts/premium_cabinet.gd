extends Node3D

const Reel = preload("res://scripts/slot_reel.gd")
const I18n = preload("res://scripts/i18n.gd")
var machine: Node3D
var display: SubViewport
var reels: Array = []
var status: Label
var title: Label
var atlas: Texture2D
var finishes: Dictionary = {}
func build(owner_machine: Node3D) -> void :
	machine = owner_machine
	atlas = load("res://assets/art/premium-circus-atlas.png")
	name = "PremiumCabinet"
	block(Vector3(0, -0.66, 0), Vector3(7.6, 0.92, 7.35), "082354", 0.55)
	block(Vector3(0, -0.107, 0.05), Vector3(6.05, 0.22, 5.9), "a7b5c1", 0.94)
	block(Vector3(0, 0.54, -3.08), Vector3(6.8, 1.45, 0.22), "84949f", 0.9)
	block(Vector3(0, 0.95, -1.88), Vector3(6, 0.8, 0.16), "94a8b7", 0.9)
	block(Vector3(0, 3.65, -1.78), Vector3(6.6, 4.35, 0.36), "092d78", 0.45)
	art(Vector3(0, 3.65, -1.59), Vector2(6.4, 4.3), Rect2(0.25, 0, 0.5, 1))
	for side in [-1, 1]:

		var x: float = side * 3.56
		cylinder(Vector3(x, 3.284, 3.0), 0.52, 7.98, "073da7", 0.35)
		curved_art(Vector3(x, 3.284, 3.0), 0.535, 7.44, Rect2(0 if side < 0 else 0.75, 0, 0.25, 1))
		for y in [-0.7, -0.55, -0.35, 5.7, 5.88, 6.12]:
			cylinder(Vector3(x, -0.7 + (y + 0.7) * 1.2, 3.0), 0.585, 0.1 if y != 6.12 else 0.18, "d1dce5", 0.94)
			cylinder(Vector3(x, -0.7 + (y + 0.7) * 1.2 + 0.055, 3.0), 0.59, 0.028, "e3b74f", 0.82)
		for edge in [-1, 1]:
			strip(Vector3(x + edge * 0.43, 3.308, 3.34), Vector3(0.027, 7.08, 0.027), "5acfff")

		block(Vector3(side * 3.0, 2.85, -1.12), Vector3(0.18, 5.65, 0.36), "c1cdd6", 0.95)
		block(Vector3(side * 2.88, 2.85, -1.02), Vector3(0.045, 5.65, 0.11), "d4b365", 0.8)
		for y in [0.3, 1.3, 2.3, 3.3, 4.3, 5.3]: bolt(Vector3(side * 3.0, y, -0.92))
		block(Vector3(side * 3.34, 0.48, 0.0), Vector3(0.4, 1.3, 6.25), "082f86", 0.45)
		block(Vector3(side * 3.34, 1.15, 0.0), Vector3(0.43, 0.12, 6.4), "b6c7d6", 0.92)
		block(Vector3(side * 3.34, 1.225, 0.0), Vector3(0.075, 0.025, 6.2), "f6cc76", 0.82)
		block(Vector3(side * 3.12, -0.1, -1.7), Vector3(0.2, 0.2, 2.5), "a1afbb", 0.94)
		block(Vector3(side * 3.12, -0.24, 1.35), Vector3(0.2, 0.12, 3.6), "101e2d", 0.5)

		beam_between(Vector3(side * 3.24, 5.76, -1.32), Vector3(side * 3.24, 7.14, 3.2), Vector2(0.2, 0.18), "bacad7", 0.94)
		beam_between(Vector3(side * 3.24, 5.64, -1.32), Vector3(side * 3.24, 7.02, 3.2), Vector2(0.09, 0.045), "dfbf76", 0.8)
		glass_side(side * 3.24)
		block(Vector3(side * 3.24, 1.21, 0.93), Vector3(0.045, 0.045, 4.1), "c1d4e3", 0.9)

		beam_between(Vector3(side * 3.235, 5.14, -0.9), Vector3(side * 3.235, 6.05, 2.08), Vector2(0.012, 0.012), "819aa9", 0.65)
		block(Vector3(side * 3.55, -0.47, 3.45), Vector3(0.72, 0.44, 1.1), "092b73", 0.5)
		block(Vector3(side * 3.55, -0.23, 3.45), Vector3(0.76, 0.06, 1.12), "b6c7d6", 0.94)

	beam_between(Vector3(0, 5.76, -1.3), Vector3(0, 7.14, 3.18), Vector2(6.36, 0.075), "263948", 0.72)
	for x in [-1.95, 1.95]:
		beam_between(Vector3(x, 5.68, -1.25), Vector3(x, 7.05, 3.16), Vector2(0.055, 0.045), "8096a6", 0.85)
	var marquee_first_child: = get_child_count()

	var crown: = PackedVector2Array([Vector2(-3.48, 5.87), Vector2(-3.48, 6.37), Vector2(-3.05, 6.55), Vector2(-2.65, 6.96), Vector2(-1.85, 7.1), Vector2(-1.0, 7.35), Vector2(0, 7.48), Vector2(1, 7.35), Vector2(1.85, 7.1), Vector2(2.65, 6.96), Vector2(3.05, 6.55), Vector2(3.48, 6.37), Vector2(3.48, 5.87)])
	plaque(crown, -0.98, 0.48, "d4a846", 0.85)
	var inset: = PackedVector2Array()
	for v in crown: inset.append(Vector2(v.x * 0.965, 6.6 + (v.y - 6.6) * 0.86))
	plaque(inset, -0.7, 0.12, "103f9d", 0.35)
	block(Vector3(0, 6.37, -0.6), Vector3(4.88, 0.9, 0.15), "ecbf65", 0.85)
	block(Vector3(0, 6.37, -0.49), Vector3(4.69, 0.75, 0.1), "900e23", 0.28)
	text3d(I18n.clown_marquee(), Vector3(0, 6.37, -0.42), 78, "fff0ac", 0.0088)
	for side in [-1, 1]:
		star(Vector3(side * 2.82, 6.4, -0.47), 0.36)
		star(Vector3(side * 1.86, 7.02, -0.56), 0.22)
		for i in range(8):
			var x: float = side * (0.92 + i * 0.3)
			bulb(Vector3(x, 7.18 - abs(x) * 0.19, -0.6), "fff0bd", 0.043)

		for i in range(18):
			var a: float = float(i) / 17.0 * PI * 1.65
			var r: float = 0.21 * (1.0 - float(i) / 24.0)
			bulb(Vector3(side * (2.82 + cos(a) * r), 6.94 + sin(a) * r, -0.57), "e9be5c", 0.055, false)
	cylinder(Vector3(0, 7.12, -0.62), 0.57, 0.13, "d6b05c", 0.85, PI / 2)
	cylinder(Vector3(0, 7.12, -0.53), 0.49, 0.14, "153ea4", 0.35, PI / 2)
	round_art(Vector3(0, 7.12, -0.36), 0.45, Rect2(0.026, 0.325, 0.205, 0.305))
	for i in range(12):
		var a: float = i * TAU / 12.0
		bulb(Vector3(cos(a) * 0.49, 7.12 + sin(a) * 0.49, -0.42), "ffe6a0", 0.032)
	block(Vector3(0, 5.78, -0.93), Vector3(6.2, 0.19, 1.1), "bacad7", 0.96)
	block(Vector3(0, 5.68, -0.95), Vector3(6.0, 0.065, 1.02), "273746", 0.8)
	for side in [-1, 1]:
		cylinder(Vector3(side * 2.23, 5.65, -0.76), 0.3, 0.045, "d2e6ed", 0.75)
		strip(Vector3(side * 2.23, 5.61, -0.75), Vector3(0.43, 0.035, 0.43), "d9f3ff")

	for i in range(marquee_first_child, get_child_count()):
		(get_child(i) as Node3D).position.z += 3.84
		(get_child(i) as Node3D).position.y += 1.38
	block(Vector3(0, 5.77, -1.17), Vector3(6.35, 0.16, 0.26), "bacad7", 0.94)

	block(Vector3(0, 4.0, -1.65), Vector3(5.14, 1.75, 0.14), "091426", 0.3)
	block(Vector3(0, 4.0, -1.55), Vector3(5.04, 1.66, 0.13), "d2ab50", 0.85)
	block(Vector3(0, 4.0, -1.47), Vector3(4.82, 1.52, 0.055), "111c2e", 0.5)
	build_screen()
	for side in [-1, 1]:
		for i in range(6): bulb(Vector3(side * 2.46, 3.32 + i * 0.27, -1.36), "ffe4a1", 0.042)
	for i in range(17):
		for y in [3.2, 4.8]: bulb(Vector3(-2.28 + i * 0.285, y, -1.36), "ffe4a1", 0.038)


	block(Vector3(0, -0.89, 3.43), Vector3(6.6, 0.12, 1), "8198aa", 0.92)
	block(Vector3(0, -0.67, 3.9), Vector3(7.35, 0.7, 0.34), "07358d", 0.45)
	art(Vector3(0, -0.67, 4.077), Vector2(7.15, 0.58), Rect2(0.25, 0.0, 0.5, 0.17))
	block(Vector3(0, -0.26, 3.89), Vector3(7.46, 0.13, 0.41), "c4d1df", 0.97)
	block(Vector3(0, -0.17, 3.91), Vector3(7.35, 0.04, 0.29), "efc76e", 0.85)
	block(Vector3(0, -1.02, 3.89), Vector3(7.38, 0.1, 0.36), "d6b259", 0.85)
	block(Vector3(0, -0.69, 4.12), Vector3(3.5, 0.39, 0.045), "0b2866", 0.4)
	text3d(I18n.clown_plaque(), Vector3(0, -0.69, 4.15), 28, "f5d58c", 0.008)
	for side in [-1, 1]: star(Vector3(side * 2.94, -0.68, 4.14), 0.23)
func beam_between(start: Vector3, end: Vector3, section: Vector2, tint: String, metal: float) -> void :
	var offset: = end - start
	var beam = block((start + end) * 0.5, Vector3(section.x, section.y, offset.length()), tint, metal)
	beam.rotation.x = - atan2(offset.y, offset.z)
func glass_side(x: float) -> void :

	var verts = [Vector3(x, 1.23, -1.12), Vector3(x, 1.23, 2.98), Vector3(x, 6.98, 2.98), Vector3(x, 5.73, -1.12)]
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in [0, 1, 2, 0, 2, 3]:
		st.set_normal(Vector3(1, 0, 0))
		st.add_vertex(verts[i])
	var glass: = MeshInstance3D.new()
	glass.mesh = st.commit()
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = Color(0.65, 0.84, 0.95, 0.035)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.12
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.material_override = mat
	add_child(glass)
func finish(tint: String, metal: float = 0.0) -> StandardMaterial3D:
	var key = tint + str(metal)
	if finishes.has(key): return finishes[key]
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = Color(tint)
	mat.metallic = metal
	mat.roughness = 0.19 if metal > 0.7 else 0.31
	finishes[key] = mat
	return mat
func block(pos: Vector3, dimensions: Vector3, tint: String, metal: = 0.0) -> Node3D:
	var node = machine.box(self, pos, dimensions, tint, false, metal)
	node.get_child(0).material_override = finish(tint, metal)
	return node
func strip(pos: Vector3, dimensions: Vector3, tint: String) -> void :
	var n = block(pos, dimensions, tint)
	var mat = finish(tint).duplicate()
	mat.emission_enabled = true
	mat.emission = Color(tint)
	mat.emission_energy_multiplier = 1.0
	n.get_child(0).material_override = mat
func cylinder(pos: Vector3, radius: float, height: float, tint: String, metal: float = 0.0, rx: float = 0.0) -> void :
	var m: = MeshInstance3D.new()
	var geo: = CylinderMesh.new()
	geo.top_radius = radius
	geo.bottom_radius = radius
	geo.height = height
	geo.radial_segments = 64
	m.mesh = geo
	m.position = pos
	m.rotation.x = rx
	m.material_override = finish(tint, metal)
	add_child(m)
func bulb(pos: Vector3, tint: String, radius: float, lit: bool = true) -> void :
	var m: = MeshInstance3D.new()
	var sphere: = SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2
	sphere.radial_segments = 12
	sphere.rings = 6
	m.mesh = sphere
	m.position = pos
	var mat = finish(tint, 0.15 if lit else 0.8).duplicate()
	if lit:
		mat.emission_enabled = true
		mat.emission = Color(tint)
		mat.emission_energy_multiplier = 0.75
	m.material_override = mat
	add_child(m)
func plaque(points: PackedVector2Array, z: float, depth: float, tint: String, metal: float) -> void :
	var geo: = CSGPolygon3D.new()
	geo.polygon = points
	geo.depth = depth
	geo.position.z = z
	geo.material = finish(tint, metal)
	add_child(geo)
func star(pos: Vector3, radius: float) -> void :
	var points: = PackedVector2Array()
	for i in range(10):
		var a: float = PI / 2 + i * PI / 5
		var r: float = radius if i % 2 == 0 else radius * 0.43
		points.append(Vector2(pos.x + cos(a) * r, pos.y + sin(a) * r))
	plaque(points, pos.z, 0.07, "f2ca68", 0.85)
func art_material(region: Rect2) -> StandardMaterial3D:
	var mat: = StandardMaterial3D.new()
	mat.albedo_texture = atlas
	mat.uv1_scale = Vector3(region.size.x, region.size.y, 1)
	mat.uv1_offset = Vector3(region.position.x, region.position.y, 0)
	mat.roughness = 0.22
	mat.metallic = 0.1
	mat.emission_enabled = true
	mat.emission_texture = atlas
	mat.emission = Color.WHITE
	mat.emission_energy_multiplier = 0.17
	return mat
func art(pos: Vector3, dimensions: Vector2, region: Rect2) -> void :
	var mesh: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = dimensions
	mesh.mesh = quad
	mesh.position = pos
	mesh.material_override = art_material(region)
	add_child(mesh)
func round_art(pos: Vector3, radius: float, region: Rect2) -> void :
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(64):
		for v in [Vector2.ZERO, Vector2(cos(i * TAU / 64.0), sin(i * TAU / 64.0)), Vector2(cos((i + 1) * TAU / 64.0), sin((i + 1) * TAU / 64.0))]:
			st.set_normal(Vector3.FORWARD)
			st.set_uv(Vector2(0.5 + v.x * 0.5, 0.5 - v.y * 0.5))
			st.add_vertex(Vector3(v.x * radius, v.y * radius, 0))
	var mesh: = MeshInstance3D.new()
	mesh.mesh = st.commit()
	mesh.position = pos
	var mat = art_material(region)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = mat
	add_child(mesh)
func curved_art(pos: Vector3, radius: float, height: float, region: Rect2) -> void :
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(48):
		for corner in [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 0), Vector2(1, 1), Vector2(0, 1)]:
			var u: float = (i + corner.x) / 48.0
			var a: float = (u - 0.5) * PI
			st.set_normal(Vector3(sin(a), 0, cos(a)))
			st.set_uv(Vector2(u, corner.y))
			st.add_vertex(Vector3(sin(a) * radius, (0.5 - corner.y) * height, cos(a) * radius))
	var mesh: = MeshInstance3D.new()
	mesh.mesh = st.commit()
	mesh.position = pos
	var mat = art_material(region)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = mat
	add_child(mesh)
func text3d(words: String, pos: Vector3, font_size: int, tint: String, pixel: float) -> void :
	var label: = Label3D.new()
	label.font = bold_font()
	label.text = words
	label.font_size = font_size
	label.pixel_size = pixel
	label.position = pos
	label.modulate = Color(tint)
	label.outline_size = 0
	add_child(label)
func bolt(pos: Vector3) -> void :
	cylinder(pos, 0.054, 0.038, "cfdbe5", 0.94, PI / 2)
	block(pos + Vector3(0, 0, 0.023), Vector3(0.062, 0.009, 0.008), "405263", 0.75)
func screen_label(words: String, pos: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var l: = Label.new()
	l.text = words
	l.position = pos
	l.size = dimensions
	l.add_theme_font_override("font", bold_font())
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color("ffe6a3"))
	display.add_child(l)
	return l
func build_screen() -> void :
	display = SubViewport.new()
	display.size = Vector2i(768, 256)
	display.disable_3d = true
	display.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(display)
	var bg: = ColorRect.new()
	bg.color = Color("111a32")
	bg.size = Vector2(768, 256)
	display.add_child(bg)
	title = screen_label(I18n.clown_screen_title(), Vector2(18, 12), Vector2(500, 38), 28)
	for i in range(3):
		var panel: = ColorRect.new()
		panel.position = Vector2(14 + i * 130, 48)
		panel.size = Vector2(120, 168)
		panel.color = Color("263d55")
		display.add_child(panel)
		var reel: = Reel.new()
		reel.size = panel.size
		reel.clip_contents = true
		panel.add_child(reel)
		reels.append(reel)
	status = screen_label(I18n.clown_screen_idle(), Vector2(425, 62), Vector2(325, 154), 34)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	screen_label("58   /   388   /   2,999   /   29,999", Vector2(20, 220), Vector2(740, 32), 25)
	var mesh: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(4.69, 1.48)
	mesh.mesh = quad
	mesh.position = Vector3(0, 4.0, -1.435)
	var mat: = StandardMaterial3D.new()
	mat.albedo_texture = display.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material_override = mat
	add_child(mesh)
func sync_bonus(bonus, practice: bool) -> void :
	if not visible: return
	title.text = I18n.clown_practice_title() if practice else I18n.clown_screen_title()
	for i in range(3):
		reels[i].rows = bonus.column(i)
		reels[i].lit = bonus.lit_rows(i)
		reels[i].set_reel(str(bonus.reels[i]), bonus.spinning, bonus.elapsed, i)
	if bonus.spinning: status.text = I18n.clown_reduced() if bonus.reduced_draw else I18n.clown_spinning()
	elif bonus.presentation > 0: status.text = I18n.clown_won(bonus.reward)
	elif bonus.remaining > 0: status.text = I18n.clown_to_drop(bonus.remaining)
	else: status.text = I18n.clown_hit_target()
	status.text += I18n.clown_spins_left(bonus.pending_spins)

func bold_font() -> FontVariation:
	var font: = FontVariation.new()
	font.base_font = load("res://assets/fonts/NotoSansSC.ttf")
	font.variation_opentype = {2003265652: 650.0}
	return font
