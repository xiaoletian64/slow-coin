extends RefCounted


const SEGMENTS: = 64
static var shared: ArrayMesh
static var silver_shared: ArrayMesh
static var plain_gold: ArrayMesh
static var plain_silver: ArrayMesh
static func get_mesh(silver_coin: = false, plain: = false) -> ArrayMesh:
	if plain:
		if silver_coin and plain_silver != null: return plain_silver
		if not silver_coin and plain_gold != null: return plain_gold
	if not plain and silver_coin and silver_shared != null: return silver_shared
	if not plain and not silver_coin and shared != null: return shared
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var profile: Array[Vector2] = [Vector2(0, -0.034), Vector2(0.183, -0.034), Vector2(0.198, -0.035), Vector2(0.204, -0.043), Vector2(0.224, -0.043), Vector2(0.235, -0.032), Vector2(0.235, 0.032), Vector2(0.224, 0.043), Vector2(0.204, 0.043), Vector2(0.198, 0.035), Vector2(0.183, 0.034), Vector2(0, 0.034)]
	for band in range(profile.size() - 1):
		var a: Vector2 = profile[band]
		var b: Vector2 = profile[band + 1]
		var normal2: = Vector2(b.y - a.y, a.x - b.x).normalized()
		for i in range(SEGMENTS):
			var t0: float = i * TAU / SEGMENTS
			var t1: float = (i + 1) * TAU / SEGMENTS
			var pts: Array[Vector3] = [Vector3(cos(t0) * a.x, a.y, sin(t0) * a.x), Vector3(cos(t1) * a.x, a.y, sin(t1) * a.x), Vector3(cos(t1) * b.x, b.y, sin(t1) * b.x), Vector3(cos(t0) * b.x, b.y, sin(t0) * b.x)]
			var tint: = Color("d6b777")
			if band in [2, 8]: tint = Color("967647")
			elif band in [3, 4, 6, 7]: tint = Color("ead5a0")
			elif band == 5: tint = Color("b39761") if i % 2 == 0 else Color("cfb47e")
			if silver_coin:
				var l: float = tint.get_luminance()
				tint = Color(l, l, l)
			for j in [0, 1, 2, 0, 2, 3]:
				var angle: float = t0 if j in [0, 3] else t1
				st.set_normal(Vector3(cos(angle) * normal2.x, normal2.y, sin(angle) * normal2.x))
				st.set_color(tint)
				st.add_vertex(pts[j])

	for side in ([] if plain else [-1.0, 1.0]):
		if silver_coin:
			var glyph: = PackedVector2Array([Vector2(-0.04, -0.035), Vector2(0.005, -0.074), Vector2(0.033, -0.074), Vector2(0.033, 0.055), Vector2(0.06, 0.055), Vector2(0.06, 0.079), Vector2(-0.03, 0.079), Vector2(-0.03, 0.055), Vector2(-0.004, 0.055), Vector2(-0.004, -0.029), Vector2(-0.025, -0.01)])
			var indices: = Geometry2D.triangulate_polygon(glyph)
			for index in indices:
				st.set_normal(Vector3.UP * side)
				st.set_color(Color(0.69, 0.69, 0.69))
				st.add_vertex(Vector3(glyph[index].x, side * 0.036, glyph[index].y))
			continue
		for i in range(10):
			var angle: float = i * TAU / 10 - PI / 2
			var next: float = (i + 1) * TAU / 10 - PI / 2
			var p: = Vector3(cos(angle) * (0.122 if i % 2 == 0 else 0.06), side * 0.036, sin(angle) * (0.122 if i % 2 == 0 else 0.06))
			var q: = Vector3(cos(next) * (0.122 if (i + 1) % 2 == 0 else 0.06), side * 0.036, sin(next) * (0.122 if (i + 1) % 2 == 0 else 0.06))
			for v in ([Vector3(0, side * 0.039, 0), q, p] if side > 0 else [Vector3(0, side * 0.039, 0), p, q]):
				st.set_normal(Vector3.UP * side)
				st.set_color(Color("ae8a4e") if i % 2 == 0 else Color("f0d69a"))
				st.add_vertex(v)
	var result: = st.commit()
	if plain:
		if silver_coin: plain_silver = result
		else: plain_gold = result
	elif silver_coin: silver_shared = result
	else: shared = result
	return result
