extends RefCounted


const BeveledBox = preload("res://scripts/beveled_box.gd")
var roots: Array[Node3D] = []
var _finishes: Array[StandardMaterial3D] = []
var _surfaces: Array[SurfaceTool] = []

func build(machine: Node3D) -> void :
	if not roots.is_empty():
		return
	_finishes = [
		_finish("aebfca", 0.88, 0.31),
		_finish("122b3c", 0.48, 0.4),
		_finish("c9ae77", 0.78, 0.28),
		_finish("415a69", 0.72, 0.44),
	]
	var tray: = _build_tray()
	_attach(machine.pusher, tray, "MachinedPusher")
	_attach(machine.second_pusher, tray, "MachinedPusher")
	_attach(machine.swing_pivot, _build_outlet(), "MachinedOutlet")
	_attach(machine.spin_target, _build_target(), "MachinedTarget")

func set_enabled(enabled: bool) -> void :
	for root in roots:
		if is_instance_valid(root):
			root.visible = enabled

func _finish(color: String, metal: float, roughness: float) -> StandardMaterial3D:
	var result: = StandardMaterial3D.new()
	result.albedo_color = Color(color)
	result.metallic = metal
	result.roughness = roughness
	return result

func _attach(parent: Node3D, mesh: ArrayMesh, part_name: String) -> void :
	var root: = Node3D.new()
	root.name = part_name
	parent.add_child(root)
	roots.append(root)
	var geometry: = MeshInstance3D.new()
	geometry.name = "BatchedMetalwork"
	geometry.mesh = mesh

	geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(geometry)

func _begin() -> void :
	_surfaces.clear()
	for _material in _finishes:
		var surface: = SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		_surfaces.append(surface)

func _commit() -> ArrayMesh:
	var mesh: = ArrayMesh.new()
	for i in range(_surfaces.size()):
		_surfaces[i].set_material(_finishes[i])
		_surfaces[i].commit(mesh)
	return mesh

func _box(center: Vector3, size: Vector3, finish: int) -> void :
	_surfaces[finish].append_from(BeveledBox.make(size), 0, Transform3D(Basis.IDENTITY, center))

func _build_tray() -> ArrayMesh:
	_begin()

	_box(Vector3(0, 0.257, 0), Vector3(5.96, 0.004, 3.24), 0)
	_box(Vector3(0, 0.036, 1.666), Vector3(5.99, 0.29, 0.032), 0)
	_box(Vector3(0, -0.09, 1.687), Vector3(5.83, 0.035, 0.01), 1)
	_box(Vector3(0, 0.165, 1.685), Vector3(5.94, 0.028, 0.011), 2)

	for x in [-1.0, 1.0]:
		_box(Vector3(x, 0.26, 0), Vector3(0.013, 0.002, 3.19), 3)
	for x in [-2.91, 2.91]:
		_box(Vector3(x, 0.26, 0), Vector3(0.019, 0.002, 3.19), 3)

	for i in range(13):
		var x: = -2.7 + float(i) * 0.45
		_box(Vector3(x, 0.26, -0.02), Vector3(0.003, 0.001, 3.1), 3)
	for x in [-2.73, -1.37, 1.37, 2.73]:
		_bolt(Vector3(x, 0.041, 1.687), 0.043)
	return _commit()

func _build_outlet() -> ArrayMesh:
	_begin()

	_box(Vector3(0, 0.118, -0.268), Vector3(0.94, 0.4, 0.1), 1)
	_box(Vector3(0, 0.292, -0.087), Vector3(0.91, 0.055, 0.34), 0)
	for side in [-1.0, 1.0]:
		_box(Vector3(side * 0.452, 0.096, -0.09), Vector3(0.06, 0.36, 0.31), 0)
		_box(Vector3(side * 0.335, -0.088, 0.054), Vector3(0.085, 0.17, 0.071), 0)
		_bolt(Vector3(side * 0.363, 0.184, 0.068), 0.037)

	_box(Vector3(0, 0.052, 0.075), Vector3(0.6, 0.037, 0.045), 2)
	for side in [-1.0, 1.0]:

		for y in [-0.31, -0.72]:
			_ring(Vector3(side * 0.288, y, 0), 0.044, 0.052, 0.105, 0, true)
		_box(Vector3(side * 0.288, -0.832, 0.105), Vector3(0.094, 0.118, 0.041), 0)
		_box(Vector3(side * 0.288, -0.82, 0.128), Vector3(0.066, 0.019, 0.01), 2)

	for x in [-0.2, -0.1, 0.0, 0.1, 0.2]:
		_box(Vector3(x, 0.192, 0.054), Vector3(0.033, 0.064, 0.016), 3)
	return _commit()

func _build_target() -> ArrayMesh:
	_begin()

	for side in [-1.0, 1.0]:
		_box(Vector3(side * 0.648, 0.005, 0.155), Vector3(0.115, 0.59, 0.185), 0)
		_box(Vector3(side * 0.648, 0.005, 0.254), Vector3(0.049, 0.39, 0.018), 2)
		_bolt(Vector3(side * 0.648, 0.226, 0.253), 0.035)
	_box(Vector3(0, 0.292, 0.155), Vector3(1.39, 0.1, 0.185), 0)
	_box(Vector3(0, 0.3, 0.255), Vector3(1.1, 0.028, 0.02), 3)
	_box(Vector3(0, -0.235, 0.139), Vector3(1.16, 0.225, 0.07), 1)
	_box(Vector3(0, -0.365, 0.149), Vector3(1.35, 0.035, 0.09), 2)
	return _commit()

func _bolt(center: Vector3, radius: float) -> void :
	_ring(center, radius * 0.42, radius, 0.018, 0)

	_disk(center + Vector3(0, 0, -0.007), radius * 0.43, 1, 6)

func _disk(center: Vector3, radius: float, finish: int, segments: int) -> void :
	for i in range(segments):
		var a: = float(i) * TAU / float(segments)
		var b: = float(i + 1) * TAU / float(segments)
		_triangle(finish, center, center + Vector3(cos(b), sin(b), 0) * radius,
			center + Vector3(cos(a), sin(a), 0) * radius, Vector3.BACK)

func _ring(center: Vector3, inner: float, outer: float, depth: float, finish: int, vertical: = false) -> void :

	var profile: Array[Vector2] = [
		Vector2(inner, depth * 0.5), Vector2(outer * 0.86, depth * 0.5),
		Vector2(outer, depth * 0.29), Vector2(outer, - depth * 0.29),
		Vector2(outer * 0.86, - depth * 0.5), Vector2(inner, - depth * 0.5),
	]
	var basis: = Basis(Vector3.RIGHT, PI / 2.0) if vertical else Basis.IDENTITY
	for j in range(profile.size()):
		var p: = profile[j]
		var q: = profile[(j + 1) % profile.size()]
		for i in range(20):
			var a: = float(i) * TAU / 20.0
			var b: = float(i + 1) * TAU / 20.0
			var vertices: Array[Vector3] = [
				Vector3(cos(a) * p.x, sin(a) * p.x, p.y),
				Vector3(cos(b) * p.x, sin(b) * p.x, p.y),
				Vector3(cos(b) * q.x, sin(b) * q.x, q.y),
				Vector3(cos(a) * q.x, sin(a) * q.x, q.y),
			]
			var normal: = basis * - (vertices[1] - vertices[0]).cross(vertices[2] - vertices[0]).normalized()
			for k in range(vertices.size()):
				vertices[k] = center + basis * vertices[k]

			_triangle(finish, vertices[0], vertices[1], vertices[2], normal)
			_triangle(finish, vertices[0], vertices[2], vertices[3], normal)

func _triangle(finish: int, a: Vector3, b: Vector3, c: Vector3, normal: Vector3) -> void :
	for point in [a, b, c]:
		_surfaces[finish].set_normal(normal)
		_surfaces[finish].add_vertex(point)
