extends Node
signal sound_played(kind: String)
var enabled: = true:
	set(value):
		enabled = value
		if not value:
			_stop_effects()
var haptics: = true
var music_enabled: = true
var bgm: AudioStreamPlayer
var players: Array[AudioStreamPlayer] = []
var event_players: Array[AudioStreamPlayer] = []
var sounds: = {}
var event_times: Dictionary = {}
var music_stream: AudioStreamWAV
const EVENT_RULES: = {
	"insert": [110, -17.0, 1], "target": [140, -15.0, 2],
	"spin": [350, -19.0, 1], "collect": [170, -20.0, 1],
	"reward_small": [450, -16.0, 3], "reward_medium": [650, -16.0, 3],
	"reward_big": [900, -17.0, 4], "reward_grand": [1200, -17.0, 5],
	"miss": [350, -23.0, 1], "alert": [850, -20.0, 4],
	"repel": [400, -19.0, 3], "theft": [650, -20.0, 3], "ui": [75, -24.0, 0],
}
var last_drop: = -1000
var last_collision: = -1000
var drop_group: = 0
var active_drop: AudioStreamPlayer
var collision_group: = 0
var group_started: = -1000
var last_clatter: = -1000

func _ready() -> void :
	bgm = AudioStreamPlayer.new()
	bgm.name = "BGM"
	bgm.process_mode = Node.PROCESS_MODE_PAUSABLE
	var music: AudioStreamWAV = load("res://assets/audio/slow-afternoon.wav").duplicate()
	music_stream = music
	music.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.loop_begin = 0
	music.loop_end = music.data.size() / 4
	bgm.stream = music
	bgm.volume_db = -18
	add_child(bgm)
	if music_enabled: bgm.play()
	for i in range(4):
		var player: = AudioStreamPlayer.new()
		player.process_mode = Node.PROCESS_MODE_PAUSABLE
		player.volume_db = -20
		add_child(player)
		players.append(player)
	for i in range(3):
		var event_player: = AudioStreamPlayer.new()
		event_player.name = "EventVoice%d" % i

		event_player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(event_player)
		event_players.append(event_player)
	_build_event_sounds()
	sounds["drop"] = make_coin_fall()
	sounds["collision"] = make_coin_collision()
	sounds["clatter"] = make_coin_clatter()

func make_coin_fall() -> AudioStreamWAV:
	var stream: = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var count: = int(0.2 * 22050)
	var bytes: = PackedByteArray()
	bytes.resize(count * 2)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 1978
	for i in range(count):
		var t: = float(i) / 22050.0
		var attack: = minf(1, t * 1500)
		var ring: = sin(TAU * 1240 * t) * exp( - t * 30) * 0.27 + sin(TAU * 2083 * t) * exp( - t * 43) * 0.17 + sin(TAU * 3179 * t) * exp( - t * 65) * 0.09
		var impact: = rng.randf_range(-1, 1) * exp( - t * 130) * 0.25
		bytes.encode_s16(i * 2, int((ring + impact) * attack * 25000))
	stream.data = bytes
	return stream

func pulse() -> void :
	if haptics and OS.has_feature("mobile"): Input.vibrate_handheld(18, 0.25)

func play(kind: String) -> void :
	if not enabled or not is_inside_tree(): return
	if kind != "drop":
		_play_event(kind)
		return
	if get_tree().paused: return
	var now: = Time.get_ticks_msec()

	if now - last_drop < 200:
		drop_group += 1
		if drop_group == 3 and active_drop != null:
			active_drop.stream = sounds.clatter
			active_drop.volume_db = -12
			active_drop.play()
			sound_played.emit("clatter")
		return
	for player in players:
		if not player.playing:
			last_drop = now
			drop_group = 1
			active_drop = player
			player.volume_db = -10
			player.stream = sounds.drop
			player.pitch_scale = randf_range(0.94, 1.06)
			player.play()
			sound_played.emit(kind)
			return

func set_music_enabled(value: bool) -> void :
	music_enabled = value
	if bgm != null:
		if value and not bgm.playing:
			bgm.stream = music_stream
			bgm.play()
		elif not value:
			bgm.stop()

func _stop_effects() -> void :
	for player in players + event_players:
		player.stop()
		player.stream = null
	active_drop = null
	drop_group = 0
	collision_group = 0

func stop_all() -> void :
	_stop_effects()
	if bgm != null:
		bgm.stop()
		bgm.stream = null

func _notification(what: int) -> void :
	if what == NOTIFICATION_PAUSED:

		_stop_effects()

func _exit_tree() -> void :
	stop_all()
	sounds.clear()
	music_stream = null
	event_times.clear()

func _play_event(kind: String) -> void :
	if not EVENT_RULES.has(kind) or not sounds.has(kind):
		return
	if get_tree().paused and kind != "ui":
		return
	var now: = Time.get_ticks_msec()
	var rules: Array = EVENT_RULES[kind]
	if now - int(event_times.get(kind, -100000)) < int(rules[0]):
		return
	var selected: AudioStreamPlayer
	for player in event_players:
		if not player.playing:
			selected = player
			break
	if selected == null:

		for player in event_players:
			var priority: = int(player.get_meta("priority", 0))
			if priority > int(rules[2]):
				continue
			if selected == null:
				selected = player
				continue
			var selected_priority: = int(selected.get_meta("priority", 0))
			var older: = int(player.get_meta("started", 0)) < int(selected.get_meta("started", 0))
			if priority < selected_priority or (priority == selected_priority and older):
				selected = player
	if selected == null:
		return
	event_times[kind] = now
	selected.stop()
	selected.stream = sounds[kind]
	selected.pitch_scale = 1.0
	selected.volume_db = float(rules[1])
	selected.set_meta("priority", int(rules[2]))
	selected.set_meta("started", now)
	selected.set_meta("kind", kind)
	selected.play()
	sound_played.emit(kind)

func _build_event_sounds() -> void :


	var cues: = {
		"insert": ["metal", [[0.0, 0.1, 660.0, 0.6], [0.045, 0.1, 990.0, 0.32]]],
		"target": ["soft", [[0.0, 0.16, 784.0, 0.65], [0.06, 0.2, 1174.66, 0.5]]],
		"spin": ["metal", [[0.0, 0.07, 220.0, 0.4], [0.055, 0.075, 277.18, 0.42], [0.115, 0.09, 329.63, 0.43], [0.185, 0.12, 440.0, 0.4]]],
		"reward_small": ["soft", [[0.0, 0.22, 523.25, 0.55], [0.12, 0.28, 659.25, 0.55], [0.24, 0.32, 783.99, 0.55]]],
		"reward_medium": ["soft", [[0.0, 0.25, 392.0, 0.55], [0.11, 0.26, 523.25, 0.52], [0.22, 0.28, 659.25, 0.52], [0.34, 0.4, 1046.5, 0.52]]],
		"reward_big": ["soft", [[0.0, 0.32, 261.63, 0.42], [0.0, 0.32, 392.0, 0.35], [0.16, 0.28, 523.25, 0.52], [0.3, 0.32, 659.25, 0.48], [0.45, 0.46, 783.99, 0.5], [0.45, 0.46, 1046.5, 0.28]]],
		"reward_grand": ["soft", [[0.0, 0.34, 261.63, 0.45], [0.0, 0.34, 392.0, 0.3], [0.14, 0.3, 523.25, 0.48], [0.28, 0.32, 659.25, 0.48], [0.42, 0.32, 783.99, 0.45], [0.6, 0.55, 1046.5, 0.42], [0.6, 0.55, 523.25, 0.34], [0.6, 0.55, 659.25, 0.28]]],
		"miss": ["soft", [[0.0, 0.14, 329.63, 0.45], [0.085, 0.18, 261.63, 0.36]]],
		"collect": ["metal", [[0.0, 0.13, 1318.51, 0.37], [0.035, 0.15, 1567.98, 0.25]]],
		"alert": ["alarm", [[0.0, 0.18, 440.0, 0.5], [0.24, 0.18, 554.37, 0.5]]],
		"repel": ["air", [[0.0, 0.18, 392.0, 0.55], [0.065, 0.2, 783.99, 0.48]]],
		"theft": ["metal", [[0.0, 0.14, 440.0, 0.45], [0.065, 0.16, 329.63, 0.42], [0.14, 0.22, 220.0, 0.4]]],
		"ui": ["soft", [[0.0, 0.075, 740.0, 0.42]]],
	}
	for kind in cues:
		sounds[kind] = _synthesize(cues[kind][1], cues[kind][0])

func _synthesize(notes: Array, timbre: String) -> AudioStreamWAV:
	var duration: = 0.0
	for note in notes:
		duration = maxf(duration, float(note[0]) + float(note[1]))
	var stream: = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var bytes: = PackedByteArray()
	bytes.resize(int((duration + 0.012) * 22050.0) * 2)
	var random: = RandomNumberGenerator.new()
	random.seed = 78231
	var filtered_noise: = 0.0
	for i in range(bytes.size() / 2):
		var time: = float(i) / 22050.0
		var sample: = 0.0
		filtered_noise = lerpf(filtered_noise, random.randf_range(-1.0, 1.0), 0.18)
		for note in notes:
			var age: = time - float(note[0])
			var length: = float(note[1])
			if age < 0.0 or age >= length:
				continue
			var frequency: = float(note[2])
			var envelope: = minf(age / 0.008, 1.0) * pow(1.0 - age / length, 2.0)
			var phase: = TAU * frequency * age
			var tone: = sin(phase) * 0.68 + sin(phase * 2.0) * 0.16 + sin(phase * 3.0) * 0.055
			match timbre:
				"metal": tone = sin(phase) * 0.57 + sin(phase * 1.503) * 0.2 * exp( - age * 25.0) + filtered_noise * 0.15 * exp( - age * 40.0)
				"alarm": tone *= 0.75 + sin(TAU * 7.0 * age) * 0.2
				"air": tone = tone * 0.5 + filtered_noise * 0.65
			sample += tone * envelope * float(note[3])
		bytes.encode_s16(i * 2, int(clampf(sample * 0.78, -0.9, 0.9) * 32767.0))
	stream.data = bytes
	return stream

func make_coin_collision() -> AudioStreamWAV:
	var stream: = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var bytes: = PackedByteArray()
	bytes.resize(int(0.105 * 22050) * 2)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 388
	for i in range(bytes.size() / 2):
		var t: = float(i) / 22050
		var ring: = sin(TAU * 1870 * t) * exp( - t * 65) * 0.3 + sin(TAU * 3023 * t) * exp( - t * 90) * 0.19 + sin(TAU * 4511 * t) * exp( - t * 115) * 0.1
		var click: = rng.randf_range(-1, 1) * exp( - t * 210) * 0.26
		bytes.encode_s16(i * 2, int((ring + click) * minf(1, t * 2200) * 25000))
	stream.data = bytes
	return stream

func play_collision(strength: float) -> void :
	if not enabled or not is_inside_tree() or get_tree().paused: return
	var now: = Time.get_ticks_msec()
	if now - group_started > 180:
		group_started = now
		collision_group = 0
	collision_group += 1
	if collision_group >= 4 and now - last_clatter > 350:
		for voice in players:
			if not voice.playing:
				last_clatter = now
				voice.stream = sounds.clatter
				voice.volume_db = -12
				voice.pitch_scale = randf_range(0.9, 1.05)
				voice.play()
				sound_played.emit("clatter")
				break

	if now - last_collision < 160 or now - last_drop < 100: return
	for player in players:
		if player.playing and player.stream == sounds.collision: return
	for player in players:
		if not player.playing:
			last_collision = now
			player.stream = sounds.collision
			player.volume_db = lerpf(-22, -14, clampf(strength, 0, 1))
			player.pitch_scale = randf_range(0.88, 1.15)
			player.play()
			sound_played.emit("collision")
			return

func make_coin_clatter() -> AudioStreamWAV:
	var stream: = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var bytes: = PackedByteArray()
	bytes.resize(int(0.3 * 22050) * 2)
	var delays: Array = [0.0, 0.007, 0.016, 0.031, 0.052, 0.069, 0.091, 0.117]
	var rng: = RandomNumberGenerator.new()
	rng.seed = 5010
	for i in range(bytes.size() / 2):
		var t: = float(i) / 22050
		var value: = 0.0
		for j in range(delays.size()):
			var age: float = t - delays[j]
			if age < 0: continue
			var f: float = 1320 + j * 247
			value += (sin(TAU * f * age) * 0.1 + sin(TAU * f * 1.677 * age) * 0.06) * exp( - age * 46) * minf(1, age * 2000)
			value += rng.randf_range(-0.06, 0.06) * exp( - age * 100)
		bytes.encode_s16(i * 2, int(clampf(value, -0.95, 0.95) * 29000))
	stream.data = bytes
	return stream
