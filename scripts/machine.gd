extends Node3D

signal coin_exited(front: bool, at: Vector3, bonus: bool)
signal spin_hit
signal metal_hit(strength: float)
signal coin_landed
signal coins_cleared(count: int)
signal coin_dropped
const Coin = preload("res://scripts/coin.gd")
const CAPACITY: = 1000
const QUEUE_LIMIT: = 1000000
var coins: = Node3D.new()
var pusher: AnimatableBody3D
var second_pusher: AnimatableBody3D
var sweep_bar: AnimatableBody3D
var mechanism: = "classic"
var phase: = 0.0
var pending: Array = []
var cooldown: = 0.0
var lane: = 0.0
var nozzle: Node3D
var swing_pivot: Node3D
var aim_phase: = 0.0
var aim_locked: = false
var release_point: = Vector3.ZERO
var release_speed: = 0.0
var camera: Camera3D
var elapsed: = 0.0
var materials: = {}
var spin_target: Node3D
var target_sign: Label3D
var hit_flash: = 0.0
var test_target: = false
var clearing: = 0.0
var upper_blocked_clock: = 0.0
var clear_clock: = 0.0
var pinboard_pegs: Array[StaticBody3D] = []
var dispenser_flaps: Array = []
var dispenser_clocks: Array = []
var premium
var arcade_cabinet
var mechanical_details
var tower
var rainbow
var premium_enabled: = false
var lighting_environment: Environment
var original_shell: Array = []
const TARGET_Y: = 2.15
const BOARD_Z: = -1.44
const DISPENSER_LIFT: = 0.45
const GUIDE_LENGTH: = 0.85
const GUIDE_RELEASE: = 1.03

func _ready() -> void :
	coins.name = "Coins"
	add_child(coins)
	build_machine()
	for node in find_children("*", "GeometryInstance3D", true, false):
		if _keep_visual(node): continue
		original_shell.append(node)
	premium = preload("res://scripts/premium_cabinet.gd").new()
	add_child(premium)
	premium.build(self)
	premium.visible = false
	arcade_cabinet = preload("res://scripts/arcade_cabinet.gd").new()
	add_child(arcade_cabinet)
	arcade_cabinet.build(self)
	mechanical_details = preload("res://scripts/mechanical_details.gd").new()
	mechanical_details.build(self)
	for node in original_shell: node.visible = false
	tower = preload("res://scripts/tower_event.gd").new()
	add_child(tower)
	tower.build(self)
	rainbow = preload("res://scripts/rainbow_ball.gd").new()
	add_child(rainbow)
	rainbow.build(self)

func material(color: String, metallic: = 0.0, emission: = false) -> StandardMaterial3D:
	var key: = color + str(metallic) + str(emission)
	if materials.has(key):
		return materials[key]
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = Color(color)
	mat.metallic = metallic
	mat.roughness = 0.32 if metallic > 0 else 0.7
	if emission:
		mat.emission_enabled = true
		mat.emission = Color(color)
		mat.emission_energy_multiplier = 1.2
	materials[key] = mat
	return mat

func box(parent: Node3D, pos: Vector3, size: Vector3, color: String, physical: = false, metallic: = 0.0) -> Node3D:
	var node: Node3D = StaticBody3D.new() if physical else Node3D.new()
	parent.add_child(node)
	node.position = pos
	var mesh: = MeshInstance3D.new()
	var cube: = BoxMesh.new()
	cube.size = size
	mesh.mesh = preload("res://scripts/beveled_box.gd").make(size)
	mesh.material_override = material(color, metallic)
	node.add_child(mesh)
	if physical:
		var collider: = CollisionShape3D.new()
		var shape: = BoxShape3D.new()
		shape.size = size
		collider.shape = shape
		node.add_child(collider)
		var pm: = PhysicsMaterial.new()
		pm.friction = 0.45
		node.physics_material_override = pm
	return node

func light_strip(pos: Vector3, size: Vector3, color: = "49d8e6") -> void :
	var node: = box(self, pos, size, color)
	(node.get_child(0) as MeshInstance3D).material_override = material(color, 0.2, true)

func label3d(text: String, pos: Vector3, font_size: int, color: String) -> void :
	var label: = Label3D.new()
	label.text = text
	label.font_size = font_size
	label.pixel_size = 0.008
	label.modulate = Color(color)
	label.outline_size = 0
	label.position = pos
	label.no_depth_test = false
	add_child(label)

func build_machine() -> void :
	var env: = WorldEnvironment.new()
	var settings: = Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("110c20")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("c5d9e6")
	settings.ambient_light_energy = 0.32
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	lighting_environment = settings
	var sky: = Sky.new()
	var sky_material: = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("344556")
	sky_material.sky_horizon_color = Color("93a5b5")
	sky_material.ground_bottom_color = Color("162434")
	sky_material.ground_horizon_color = Color("344d60")
	sky.sky_material = sky_material
	settings.sky = sky
	settings.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.environment = settings
	add_child(env)
	var key: = DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-55, -28, 0)
	key.light_color = Color("ffe4b0")
	key.light_energy = 0.68
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 22
	add_child(key)
	var fill: = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, 140, 0)
	fill.light_color = Color("83bcd6")
	fill.light_energy = 0.3
	add_child(fill)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.size = 8.4
	camera.fov = 32.0
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.position = Vector3(0, 8.3, 14.8)
	add_child(camera)
	camera.look_at(Vector3(0, 2.15, 0))
	camera.current = true

	box(self, Vector3(0, -0.65, 0), Vector3(7.25, 0.85, 7.2), "183644", false, 0.25)
	box(self, Vector3(0, -0.11, 0.05), Vector3(6.05, 0.22, 5.9), "214856", true, 0.35)
	box(self, Vector3(0, 0.55, -3.08), Vector3(6.8, 1.45, 0.22), "183543", true, 0.45)
	box(self, Vector3(0, 1.47, -3.05), Vector3(7.14, 0.48, 0.4), "254452", false, 0.45)
	light_strip(Vector3(0, 1.73, -2.98), Vector3(6.9, 0.035, 0.08), "f1c777")
	label3d("C O I N   C L U B", Vector3(0, 1.5, -2.79), 44, "ffe5a7")
	for side in [-1, 1]:
		box(self, Vector3(side * 3.35, 0.48, -0.02), Vector3(0.3, 1.3, 6.25), "244957", true, 0.35)
		box(self, Vector3(side * 3.38, 1.15, -0.08), Vector3(0.25, 0.11, 6.45), "b78c52", false, 0.7)
		light_strip(Vector3(side * 3.16, 0.62, 0), Vector3(0.038, 0.04, 5.7))

		box(self, Vector3(side * 3.12, -0.1, -1.7), Vector3(0.2, 0.2, 2.5), "284b57", true)
		box(self, Vector3(side * 3.12, -0.24, 1.35), Vector3(0.2, 0.12, 3.6), "071822")
		for z in [-2.7, -1.9, -1.1, -0.3, 0.5, 1.3, 2.1, 2.8]:
			light_strip(Vector3(side * 3.37, 1.22, z), Vector3(0.07, 0.025, 0.09), "f480bb")

	box(self, Vector3(0, 0.95, -1.88), Vector3(6.0, 0.8, 0.16), "244957", true, 0.35)
	light_strip(Vector3(0, 1.36, -1.78), Vector3(5.9, 0.025, 0.06), "8ecdb9")

	for x in [-2.0, 0.0, 2.0]:
		light_strip(Vector3(x, 0.005, 0.8), Vector3(0.015, 0.01, 4.3), "32636d")

	pusher = AnimatableBody3D.new()
	pusher.sync_to_physics = false
	pusher.position = Vector3(0, 0.24, -3.45)
	add_child(pusher)
	var pm: = PhysicsMaterial.new()
	pm.friction = 0.6
	pusher.physics_material_override = pm
	var mesh: = MeshInstance3D.new()
	var cube: = BoxMesh.new()
	cube.size = Vector3(6.0, 0.48, 3.26)
	mesh.mesh = cube
	mesh.material_override = material("b59662", 0.65)
	pusher.add_child(mesh)
	var collider: = CollisionShape3D.new()
	var shape: = BoxShape3D.new()
	shape.size = cube.size
	collider.shape = shape
	pusher.add_child(collider)
	box(pusher, Vector3(0, 0.247, 0), Vector3(5.97, 0.014, 3.27), "315660", false, 0.55)
	box(pusher, Vector3(0, 0.14, 1.61), Vector3(6.0, 0.065, 0.025), "f3ce80", false, 0.65)
	second_pusher = pusher.duplicate() as AnimatableBody3D
	second_pusher.position = Vector3(1.53, 0.24, -3.45)
	add_child(second_pusher)
	second_pusher.visible = false
	second_pusher.collision_layer = 0
	second_pusher.collision_mask = 0
	sweep_bar = AnimatableBody3D.new()
	sweep_bar.sync_to_physics = false
	sweep_bar.position = Vector3(0, 0.18, 1.75)
	add_child(sweep_bar)
	var bar_mesh: = MeshInstance3D.new()
	var bar_box: = BoxMesh.new()
	bar_box.size = Vector3(4.8, 0.22, 0.18)
	bar_mesh.mesh = bar_box
	bar_mesh.material_override = material("c26ca9", 0.55)
	sweep_bar.add_child(bar_mesh)
	var bar_collision: = CollisionShape3D.new()
	var bar_shape: = BoxShape3D.new()
	bar_shape.size = bar_box.size
	bar_collision.shape = bar_shape
	sweep_bar.add_child(bar_collision)
	sweep_bar.visible = false
	sweep_bar.collision_layer = 0
	sweep_bar.collision_mask = 0
	update_pusher()

	box(self, Vector3(0, -0.93, 3.43), Vector3(6.6, 0.16, 1.0), "102a36")
	box(self, Vector3(0, -0.65, 3.9), Vector3(7.15, 0.66, 0.22), "244957", false, 0.4)
	light_strip(Vector3(0, -0.28, 3.99), Vector3(6.9, 0.055, 0.07), "edc278")
	label3d("C O I N   R E T U R N", Vector3(0, -0.64, 4.03), 28, "b9d5d8")
	swing_pivot = Node3D.new()
	swing_pivot.position = Vector3(0, 5.1, BOARD_Z)
	add_child(swing_pivot)
	for side in [-1, 1]:
		var rail: = MeshInstance3D.new()
		rail.name = "GuideRailLeft" if side < 0 else "GuideRailRight"
		var cylinder: = CylinderMesh.new()
		cylinder.top_radius = 0.042
		cylinder.bottom_radius = 0.042
		cylinder.height = GUIDE_LENGTH
		cylinder.radial_segments = 20
		rail.mesh = cylinder
		rail.position = Vector3(side * 0.288, - GUIDE_LENGTH / 2, 0)
		rail.material_override = material("c7d3dc", 0.82)
		swing_pivot.add_child(rail)
		box(swing_pivot, Vector3(side * 0.288, - GUIDE_LENGTH + 0.02, 0), Vector3(0.115, 0.18, 0.18), "879daf", false, 0.8)
	box(swing_pivot, Vector3(0, -0.07, -0.14), Vector3(0.72, 0.17, 0.1), "718da4", false, 0.8)
	nozzle = Node3D.new()
	swing_pivot.add_child(nozzle)
	nozzle.position = Vector3(0, - GUIDE_LENGTH, 0)


	build_pinboard()
	build_dispenser()
	add_finish_details()
	add_marquee()
	update_aim()

func build_pinboard() -> void :
	box(self, Vector3(0, 3.5, -1.69), Vector3(6.25, 3.65, 0.12), "132b52")
	var art: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(6.25, 3.65)
	art.mesh = quad
	art.position = Vector3(0, 3.5, -1.62)
	var artwork: = StandardMaterial3D.new()
	artwork.albedo_texture = load("res://assets/art/circus-panel.svg")
	artwork.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	art.material_override = artwork
	add_child(art)
	for side in [-1, 1]:
		box(self, Vector3(side * 3.0, 3.6, BOARD_Z), Vector3(0.12, 3.8, 0.4), "c7995e", true, 0.7)
		light_strip(Vector3(side * 3.12, 3.6, -1.39), Vector3(0.07, 3.8, 0.08), "49d8e6")
	for row in range(2):
		for col in range(4 if row == 0 else 3):
			var peg: = StaticBody3D.new()
			pinboard_pegs.append(peg)
			peg.position = Vector3(-1.95 + col * 1.3 + (0.65 if row % 2 else 0.0), 3.15 - row * 0.7, BOARD_Z)
			add_child(peg)
			var mesh: = MeshInstance3D.new()
			var cylinder: = CylinderMesh.new()
			cylinder.top_radius = 0.095
			cylinder.bottom_radius = 0.095
			cylinder.height = 0.3
			mesh.mesh = cylinder
			mesh.rotation.x = PI / 2
			mesh.material_override = material("edc278", 0.7)
			peg.add_child(mesh)
			var collider: = CollisionShape3D.new()
			var shape: = CylinderShape3D.new()
			shape.radius = 0.095
			shape.height = 0.3
			collider.shape = shape
			collider.rotation.x = PI / 2
			peg.add_child(collider)
	spin_target = Node3D.new()
	spin_target.position = Vector3(0, TARGET_Y, BOARD_Z)
	add_child(spin_target)
	for x in [-0.58, 0.58]:
		box(spin_target, Vector3(x, 0, 0.16), Vector3(0.08, 0.45, 0.12), "49d8e6")
	box(spin_target, Vector3(0, 0.25, 0.16), Vector3(1.24, 0.06, 0.12), "edc278")
	var sign: = Label3D.new()
	sign.text = "S P I N"
	sign.position = Vector3(0, -0.22, 0.22)
	sign.font_size = 44
	sign.pixel_size = 0.007
	spin_target.add_child(sign)
	target_sign = sign

func _physics_process(delta: float) -> void :
	upper_blocked_clock = upper_blocked_clock + delta if pinboard_count() >= 28 else 0.0
	if upper_blocked_clock >= 2.5 and clearing <= 0:
		shake_clear()
		upper_blocked_clock = 0.0
	phase = fmod(phase + delta, 4.8)
	if clearing > 0 and shakeable_count() == 0:
		clearing = 0
		clear_clock = 0
	if clearing > 0:
		clearing = maxf(0, clearing - delta)
		clear_clock -= delta
		if clear_clock <= 0:
			clear_clock = 0.85
			shake_upper_coins()
	update_shake_pegs(delta)
	if not aim_locked:
		aim_phase = fmod(aim_phase + delta, 5.6)
	update_aim()
	update_pusher()
	spin_target.position.x = 0.0 if test_target else sin(phase / 4.8 * TAU) * 2.1
	for i in range(dispenser_flaps.size()):
		dispenser_clocks[i] = maxf(0, dispenser_clocks[i] - delta)
		dispenser_flaps[i].rotation.x = - sin(dispenser_clocks[i] / 0.24 * PI) * 0.9
	hit_flash = maxf(0.0, hit_flash - delta)
	target_sign.text = "HIT!" if hit_flash > 0 else "S P I N"
	target_sign.modulate = Color("fff08a") if hit_flash > 0 else Color.WHITE
	update_guided_coins(delta)
	update_pinboard_coins(delta)
	cooldown = maxf(0, cooldown - delta)
	if clearing <= 0 and not pending.is_empty() and cooldown <= 0 and pinboard_count() < 32 and guide_mouth_clear():
		var shot = pending.pop_front()
		if shot is float or shot is int:
			shot = {"x": shot, "y": 1.18, "vx": 0.0}
		if shot.get("guided", false): spawn_guided_coin()
		else: spawn_pinboard_coin(Vector3(float(shot.x), float(shot.y), BOARD_Z), Vector3(float(shot.vx) + randf_range(-0.12, 0.12), -0.3, 0))
		cooldown = 0.13
		coin_dropped.emit()
	settle_exits()
	tower.tick(delta)
	rainbow.tick(delta)


func update_pinboard_coins(delta: = 1.0 / 60.0) -> void :
	for coin in coins.get_children():
		if not coin.in_pinboard or coin.guide_distance >= 0: continue
		coin.collision_mask = 0 if test_target else 1
		if test_target:
			coin.position.x = 0
			coin.linear_velocity.x = 0

		coin.pin_stall = coin.pin_stall + delta if coin.linear_velocity.length() < 0.12 else 0.0
		if coin.pin_stall > 0.6:
			coin.apply_central_impulse(Vector3(0.006 if randf() > 0.5 else -0.006, 0, 0))
			coin.pin_stall = 0.0
		if not coin.target_checked and coin.position.y <= TARGET_Y:
			coin.target_checked = true
			if coin.previous_y > TARGET_Y and absf(coin.position.x - spin_target.position.x) < 0.46:
				hit_flash = 1.0
				spin_hit.emit()
		coin.previous_y = coin.position.y
		if coin.position.y < 1.8:
			coin.set_pinboard(false)
			coin.collision_mask = 1
			coin.linear_velocity.z = 0.7

func update_aim() -> void :
	var angle: = sin(aim_phase / 5.6 * TAU) * 0.98
	swing_pivot.rotation.z = angle
	release_point = nozzle.global_position + Vector3(0, -0.18, 0)
	lane = release_point.x
	release_speed = 0.0 if aim_locked else cos(aim_phase / 5.6 * TAU) * cos(angle) * 0.42

func toggle_aim() -> void :
	aim_locked = not aim_locked
	update_aim()

func update_pusher() -> void :
	var front: = -1.8 + (1.0 - cos(phase / 4.8 * TAU)) * 1.2
	pusher.position = Vector3(-1.53 if mechanism == "split" else 0.0, 0.24, front - 1.65)
	if second_pusher != null:
		var other_front: float = -1.8 + (1.0 - cos((phase + 2.4) / 4.8 * TAU)) * 1.2
		second_pusher.position = Vector3(1.53, 0.24, other_front - 1.65)
	if sweep_bar != null:
		sweep_bar.rotation.y = sin(phase / 4.8 * TAU) * 0.28

func accepts_coin() -> bool:
	return pending.size() < QUEUE_LIMIT

func enqueue(x: float) -> bool:
	if not accepts_coin():
		return false
	pending.append({"guided": true, "x": clampf(x, -2.55, 2.55), "y": release_point.y, "vx": release_speed})
	return true

func pinboard_count() -> int:
	var count: = 0
	for coin in coins.get_children():
		if coin.in_pinboard: count += 1
	return count

func spawn_pinboard_coin(pos: Vector3, velocity: Vector3, is_bonus: = false):
	var coin = spawn_coin(pos)
	coin.rotation = Vector3(PI / 2, 0, 0)
	coin.set_pinboard(true)
	coin.previous_y = coin.position.y
	coin.linear_velocity = velocity
	coin.bonus_coin = is_bonus
	return coin

func spawn_coin(pos: Vector3):
	var coin = Coin.new()
	coin.metal_hit.connect( func(strength): metal_hit.emit(strength))
	coin.surface_hit.connect( func(): coin_landed.emit())
	coins.add_child(coin)
	coin.position = pos
	coin.set_silver(premium_enabled)
	clear_overflow(coin)
	return coin

func clear_overflow(new_coin) -> void :
	if coins.get_child_count() <= CAPACITY: return
	var candidates: Array = []
	for coin in coins.get_children():
		if coin != new_coin and not coin.in_pinboard: candidates.append(coin)
	if candidates.size() < 50:
		for coin in coins.get_children():
			if coin != new_coin and coin not in candidates: candidates.append(coin)
	candidates.shuffle()
	for i in range(50):
		coins.remove_child(candidates[i])
		candidates[i].queue_free()
	coins_cleared.emit(50)

func settle_exits() -> void :
	for coin in coins.get_children():
		if coin.position.y < -0.35:
			var at: Vector3 = coin.position
			var front: bool = at.z >= 2.92 and absf(at.x) < 3.03
			coins.remove_child(coin)
			coin.queue_free()
			coin_exited.emit(front, at, coin.bonus_coin)

func seed_coins() -> void :
	var rng: = RandomNumberGenerator.new()
	rng.seed = 4812
	for row in range(7):
		for col in range(12):
			var x: = -2.65 + col * 0.48 + (0.1 if row % 2 else 0.0)
			var point: = Vector3(x + rng.randf_range(-0.052, 0.052), 0.06 + rng.randf_range(0, 0.012), -0.03 + row * 0.47 + rng.randf_range(-0.05, 0.05))
			if mechanism == "split" and x > 0 and point.z < 0.85: point.y = 0.55
			if mechanism == "sweep" and absf(point.z - 1.75) < 0.35: point.y = 0.42
			var coin = spawn_coin(point)
			coin.rotation = Vector3(rng.randf_range(-0.08, 0.08), rng.randf() * TAU, rng.randf_range(-0.08, 0.08))
	for row in range(2):
		for col in range(11):
			var coin = spawn_coin(Vector3(-2.5 + col * 0.49, 0.54, -1.5 + row * 0.5))
			coin.rotation.y = rng.randf() * TAU
	for i in range(14):
		var coin = spawn_coin(Vector3(rng.randf_range(-2.5, 2.5), 0.23, rng.randf_range(0.3, 2.3)))
		coin.rotation = Vector3(rng.randf_range(-0.28, 0.28), rng.randf() * TAU, rng.randf_range(-0.28, 0.28))

	for i in range(8):
		spawn_coin(Vector3(-0.72 + (i % 4) * 0.48, 0.16, 2.07 + (i / 4) * 0.48))

func clear_coins() -> void :
	for coin in coins.get_children():
		coins.remove_child(coin)
		coin.queue_free()

func snapshot() -> Dictionary:
	var rows: Array = []
	for coin in coins.get_children():
		rows.append(coin.snapshot())
	return {"rainbow": rainbow.snapshot(), "tower": tower.snapshot(), "phase": phase, "clearing": clearing, "clear_clock": clear_clock, "cooldown": cooldown, "aim_phase": aim_phase, "aim_locked": aim_locked, "coins": rows, "queue": pending.duplicate()}

static func valid_snapshot(data: Dictionary) -> bool:
	if data.has("rainbow") and not preload("res://scripts/rainbow_ball.gd").valid(data.rainbow): return false
	if data.has("tower") and not preload("res://scripts/tower_event.gd").valid(data.tower): return false
	if not data.get("coins") is Array or not data.get("queue") is Array:
		return false
	if data.coins.size() > CAPACITY or data.queue.size() > QUEUE_LIMIT:
		return false
	for key in ["phase", "cooldown"]:
		var value = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or float(value) < 0 or float(value) > 5:
			return false
	for key in ["clearing", "clear_clock"]:
		var value = data.get(key, 0.0)
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0 or value > 6: return false
	for entry in data.coins:
		if not entry is Dictionary or not Coin.valid(entry):
			return false
	for shot in data.queue:
		if shot is int or shot is float:
			if not is_finite(float(shot)) or absf(float(shot)) > 2.55:
				return false
		elif shot is Dictionary:
			for key in ["x", "y", "vx"]:
				var value = shot.get(key)
				if not (value is int or value is float) or not is_finite(float(value)):
					return false
			if not shot.get("guided", false) is bool: return false
			if absf(shot.x) > 2.55 or shot.y < 0.5 or shot.y > 6.0 or absf(shot.vx) > 1.0:
				return false
		else:
			return false
	var aim = data.get("aim_phase", 0.0)
	if not (aim is int or aim is float) or not is_finite(float(aim)) or aim < 0 or aim > 5.6 or not data.get("aim_locked", false) is bool:
		return false
	return true

func configure_mechanism(id: String) -> void :
	mechanism = id
	pusher.scale.x = 0.49 if id == "split" else 1.0
	second_pusher.scale.x = 0.49
	second_pusher.visible = id == "split"
	second_pusher.collision_layer = 1 if id == "split" else 0
	second_pusher.collision_mask = 1 if id == "split" else 0
	sweep_bar.visible = id == "sweep"
	sweep_bar.collision_layer = 1 if id == "sweep" else 0
	sweep_bar.collision_mask = 1 if id == "sweep" else 0
	teleport_pusher()

func teleport_pusher() -> void :

	for body in [pusher, second_pusher, sweep_bar]:
		PhysicsServer3D.body_set_mode(body.get_rid(), PhysicsServer3D.BODY_MODE_STATIC)
	update_pusher()
	for body in [pusher, second_pusher, sweep_bar]:
		PhysicsServer3D.body_set_state(body.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, body.global_transform)
		PhysicsServer3D.body_set_mode(body.get_rid(), PhysicsServer3D.BODY_MODE_KINEMATIC)

func restore(data: Dictionary) -> void :
	clear_coins()
	pending.clear()
	if not valid_snapshot(data):
		tower.restore({})
		rainbow.restore({})
		clearing = 0.0
		clear_clock = 0.0
		update_shake_pegs(1.0)
		phase = 0.0
		cooldown = 0
		aim_phase = 0
		aim_locked = false
		update_aim()
		teleport_pusher()
		seed_coins()
		return
	tower.restore(data.get("tower", {}))
	rainbow.restore(data.get("rainbow", {}))
	clearing = clampf(float(data.get("clearing", 0.0)), 0, 6)
	clear_clock = clampf(float(data.get("clear_clock", 0.0)), 0, 0.85)
	update_shake_pegs(1.0)
	phase = float(data.phase)
	aim_phase = float(data.get("aim_phase", 0.0))
	aim_locked = data.get("aim_locked", false)
	update_aim()
	cooldown = float(data.cooldown)
	pending = data.queue.duplicate()
	teleport_pusher()
	for row in data.coins:
		var coin = spawn_coin(Coin.unvec(row.p))
		coin.rotation = Coin.unvec(row.r)
		coin.linear_velocity = Coin.unvec(row.v)
		coin.angular_velocity = Coin.unvec(row.a)
		coin.sleeping = row.s
		coin.bonus_coin = row.get("bonus", false)
		coin.set_pinboard(row.get("pinboard", false))
		coin.target_checked = row.get("target_checked", false)
		coin.previous_y = float(row.get("previous_y", coin.position.y))
		coin.pin_stall = float(row.get("pin_stall", 0.0))
		coin.guide_distance = float(row.get("guide_distance", -1.0))
		coin.guide_speed = float(row.get("guide_speed", 2.0))
		if coin.guide_distance >= 0:
			coin.freeze = true
			coin.collision_layer = 0
			coin.collision_mask = 0

func apply_skin(id: String) -> void :
	premium_enabled = id == "clown_deluxe"
	premium.visible = premium_enabled
	premium.display.render_target_update_mode = SubViewport.UPDATE_ALWAYS if premium_enabled else SubViewport.UPDATE_DISABLED
	for node in original_shell: node.visible = false
	arcade_cabinet.visible = not premium_enabled
	mechanical_details.set_enabled( not premium_enabled)
	for coin in coins.get_children(): coin.set_silver(premium_enabled)
	camera.position = Vector3(0, 6.8, 17.8) if premium_enabled else Vector3(0, 8.3, 16.0)
	camera.fov = 37.5 if premium_enabled else 35.5
	camera.look_at(Vector3(0, 3.2, 0) if premium_enabled else Vector3(0, 1.8, 0))
	var skins = preload("res://scripts/wallet.gd").SKINS
	var skin: Dictionary = skins.get(id, skins.classic)
	arcade_cabinet.set_style(id)
	arcade_cabinet.apply_palette(Color(skin.body), Color(skin.trim))
	for key in materials:
		var source: String = key.left(6)
		var mat: StandardMaterial3D = materials[key]
		if source in ["244957", "254452", "183644", "183543"]:
			mat.albedo_color = Color(skin.body)
		elif source in ["b59662", "315660", "c26ca9"]:
			if premium_enabled:
				mat.albedo_color = Color("626d78") if source == "b59662" else (Color(skin.bed) * 0.6 if source == "315660" else Color("c26ca9"))
				mat.metallic = 0.65 if source == "b59662" else 0.55
				mat.roughness = 0.32
			else:
				mat.albedo_color = Color("a7b5c1" if source == "b59662" else "8798a6")
				mat.metallic = 0.82
				mat.roughness = 0.34
		elif source in ["214856", "315660", "284b57"]:
			mat.albedo_color = Color(skin.bed) * (0.6 if premium_enabled else 1.0)
		elif source in ["b78c52", "b59662", "b68f56", "ba965b"]:
			mat.albedo_color = Color("626d78") if premium_enabled and source == "b59662" else Color(skin.trim)

func build_dispenser() -> void :

	var head = Node3D.new()
	head.name = "MovingOutlet"
	swing_pivot.add_child(head)
	box(head, Vector3(0, 0.1, -0.1), Vector3(0.86, 0.46, 0.3), "b78c52", false, 0.7)
	box(head, Vector3(0, -0.08, 0.065), Vector3(0.52, 0.18, 0.035), "070b18")
	var flap = box(head, Vector3(0, -0.18, 0.04), Vector3(0.54, 0.045, 0.14), "edc278", false, 0.7)
	dispenser_flaps.append(flap)
	dispenser_clocks.append(0.0)

func guide_mouth_clear() -> bool:
	var mouth: = swing_pivot.to_global(Vector3(0, -0.24, 0))
	for coin in coins.get_children():
		if coin.position.distance_to(mouth) < Coin.RADIUS * 2.1: return false
	return true

func dispense_bonus(_tier: int, _emitted: int):
	if not guide_mouth_clear(): return null
	dispenser_clocks[0] = 0.24
	return spawn_guided_coin(true)

func shake_upper_coins() -> void :
	for coin in coins.get_children():
		if not coin.in_pinboard or coin.guide_distance >= 0: continue
		coin.sleeping = false


		coin.apply_central_impulse(Vector3(0.012 if randf() > 0.5 else -0.012, -0.012, 0))

func update_shake_pegs(delta: float) -> void :


	var target_z: = BOARD_Z - 0.42 if clearing > 0 else BOARD_Z
	for peg in pinboard_pegs:
		peg.position.z = move_toward(peg.position.z, target_z, 3.5 * delta)
		peg.collision_layer = 0 if clearing > 0 or not is_equal_approx(peg.position.z, BOARD_Z) else 1

func shake_clear() -> void :
	if shakeable_count() == 0: return
	clearing = 6.0
	clear_clock = 0.0
	update_shake_pegs(0.0)

func add_finish_details() -> void :
	var glass: = StandardMaterial3D.new()
	glass.albedo_color = Color(0.6, 0.87, 0.95, 0.12)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.roughness = 0.12
	glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	for side in [-1, 1]:
		var panel: = box(self, Vector3(side * 3.17, 1.45, -0.1), Vector3(0.025, 0.6, 5.7), "719aad")
		(panel.get_child(0) as MeshInstance3D).material_override = glass
		box(self, Vector3(side * 3.17, 1.76, -0.1), Vector3(0.08, 0.055, 5.8), "bac9d1", false, 0.85)
		box(self, Vector3(side * 3.17, 1.44, 2.77), Vector3(0.08, 0.65, 0.08), "bac9d1", false, 0.85)
		for z in [-2.7, -1.6, -0.5, 0.6, 1.7, 2.75]:
			var screw: = MeshInstance3D.new()
			var cylinder: = CylinderMesh.new()
			cylinder.top_radius = 0.045
			cylinder.bottom_radius = 0.045
			cylinder.height = 0.025
			cylinder.radial_segments = 12
			screw.mesh = cylinder
			screw.material_override = material("b5c2c9", 0.85)
			screw.position = Vector3(side * 3.38, 1.22, z)
			add_child(screw)

		box(self, Vector3(side * 3.52, 0.27, 0.4), Vector3(0.055, 0.54, 4.9), "153f5b", false, 0.4)
		light_strip(Vector3(side * 3.55, 0.52, 0.4), Vector3(0.025, 0.025, 4.85), "53d4e7")
	box(self, Vector3(0, -0.47, 4.04), Vector3(6.65, 0.16, 0.12), "b8c8cf", false, 0.85)
	box(self, Vector3(0, -0.56, 4.11), Vector3(5.9, 0.1, 0.035), "07121c")
	for x in [-2.8, 2.8]:
		box(self, Vector3(x, -0.72, 4.04), Vector3(0.18, 0.16, 0.04), "c2aa74", false, 0.75)

func add_marquee() -> void :
	box(self, Vector3(0, 5.99, BOARD_Z - 0.13), Vector3(6.85, 0.67, 0.36), "17324d", false, 0.5)
	box(self, Vector3(0, 6.32, BOARD_Z + 0.08), Vector3(6.95, 0.075, 0.12), "c2aa74", false, 0.8)
	box(self, Vector3(0, 5.64, BOARD_Z + 0.08), Vector3(6.85, 0.07, 0.1), "c2aa74", false, 0.8)
	for side in [-1, 1]:
		box(self, Vector3(side * 3.32, 4.66, BOARD_Z - 0.1), Vector3(0.2, 3.3, 0.27), "17324d", false, 0.5)
		light_strip(Vector3(side * 3.42, 4.69, BOARD_Z + 0.06), Vector3(0.04, 3.16, 0.04), "62ddea")
	label3d("C I R C U S", Vector3(-1.74, 6.0, BOARD_Z + 0.11), 45, "ffe0a0")
	label3d("C O I N  C L U B", Vector3(1.65, 6.0, BOARD_Z + 0.11), 32, "ffe0a0")
	var pivot: = MeshInstance3D.new()
	var hub: = CylinderMesh.new()
	hub.top_radius = 0.25
	hub.bottom_radius = 0.28
	hub.height = 0.16
	hub.radial_segments = 48
	pivot.mesh = hub
	pivot.material_override = material("c2aa74", 0.85)
	pivot.position = Vector3(0, 5.1, BOARD_Z - 0.18)
	pivot.rotation.x = PI / 2
	add_child(pivot)

func _keep_visual(node: Node) -> bool:
	for root_node in [coins, pusher, second_pusher, sweep_bar, spin_target, swing_pivot]:
		if root_node == node or root_node.is_ancestor_of(node): return true
	for flap in dispenser_flaps:
		if flap == node or flap.is_ancestor_of(node): return true
	return node is MeshInstance3D and node.mesh is CylinderMesh and node.get_parent() is StaticBody3D

func spawn_guided_coin(is_bonus: = false):
	var coin = spawn_pinboard_coin(swing_pivot.to_global(Vector3(0, -0.24, 0)), Vector3.ZERO, is_bonus)
	coin.guide_distance = 0.24
	coin.guide_speed = 3.8
	coin.freeze = true
	coin.collision_layer = 0
	coin.collision_mask = 0
	return coin
func update_guided_coins(delta: float) -> void :
	for coin in coins.get_children():
		if coin.guide_distance < 0: continue

		coin.guide_speed = minf(5.5, coin.guide_speed + 6.0 * cos(swing_pivot.rotation.z) * delta)
		coin.guide_distance += coin.guide_speed * delta
		coin.position = swing_pivot.to_global(Vector3(0, - minf(coin.guide_distance, GUIDE_RELEASE), 0))
		if coin.guide_distance < GUIDE_RELEASE: continue
		coin.guide_distance = -1
		coin.freeze = false
		coin.collision_layer = 1
		coin.collision_mask = 1
		coin.linear_velocity = swing_pivot.basis * Vector3(0, - coin.guide_speed, 0)
		if test_target:
			coin.position.x = 0
			coin.linear_velocity.x = 0
			coin.collision_mask = 0
		coin.previous_y = coin.position.y
func shakeable_count() -> int:
	var count: = 0
	for coin in coins.get_children():
		if coin.in_pinboard and coin.guide_distance < 0: count += 1
	return count

func apply_coin_stamp(texture: Texture2D) -> void :
	Coin.set_custom_stamp(texture)
	for coin in coins.get_children(): coin.set_silver(premium_enabled)
