extends Node
signal sound_played(kind: String)
var enabled := true
var haptics := true
var music_enabled := true
var bgm: AudioStreamPlayer
var players: Array[AudioStreamPlayer] = []
var sounds := {}
var last_drop := -1000
var last_collision := -1000
var drop_group:=0
var active_drop:AudioStreamPlayer
var collision_group:=0
var group_started:=-1000
var last_clatter:=-1000

func _ready() -> void:
	bgm=AudioStreamPlayer.new()
	bgm.name="BGM"
	bgm.process_mode=Node.PROCESS_MODE_PAUSABLE
	var music:AudioStreamWAV=load("res://assets/audio/slow-afternoon.wav")
	music.loop_mode=AudioStreamWAV.LOOP_FORWARD
	music.loop_begin=0
	music.loop_end=music.data.size()/4
	bgm.stream=music
	bgm.volume_db=-18
	add_child(bgm)
	bgm.play()
	for i in range(6):
		var player := AudioStreamPlayer.new()
		player.volume_db = -20
		add_child(player)
		players.append(player)
	sounds["drop"] = make_coin_fall()
	sounds["collision"] = make_coin_collision()
	sounds["clatter"] = make_coin_clatter()

func make_coin_fall() -> AudioStreamWAV:
	var stream:=AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=22050
	var count:=int(0.20*22050)
	var bytes:=PackedByteArray()
	bytes.resize(count*2)
	var rng:=RandomNumberGenerator.new()
	rng.seed=1978
	for i in range(count):
		var t:=float(i)/22050.0
		var attack:=minf(1,t*1500)
		var ring:=sin(TAU*1240*t)*exp(-t*30)*0.27+sin(TAU*2083*t)*exp(-t*43)*0.17+sin(TAU*3179*t)*exp(-t*65)*0.09
		var impact:=rng.randf_range(-1,1)*exp(-t*130)*0.25
		bytes.encode_s16(i*2,int((ring+impact)*attack*25000))
	stream.data=bytes
	return stream

func pulse() -> void:
	if haptics and OS.has_feature("mobile"):Input.vibrate_handheld(18,0.25)

func play(kind: String) -> void:
	if not enabled or kind!="drop":return
	var now:=Time.get_ticks_msec()
	# A group falling together makes one short clatter, never a queue of ticks.
	if now-last_drop<200:
		drop_group+=1
		if drop_group==3 and active_drop!=null:
			active_drop.stream=sounds.clatter
			active_drop.volume_db=-12
			active_drop.play()
			sound_played.emit("clatter")
		return
	for player in players:
		if not player.playing:
			last_drop=now
			drop_group=1
			active_drop=player
			player.volume_db=-10
			player.stream=sounds.drop
			player.pitch_scale=randf_range(0.94,1.06)
			player.play()
			sound_played.emit(kind)
			return

func set_music_enabled(value: bool) -> void:
	music_enabled=value
	if bgm!=null:
		if value and not bgm.playing:
			bgm.play()
		elif not value:
			bgm.stop()

func stop_all() -> void:
	for player in players:
		player.stop()
		player.stream=null
	if bgm!=null:
		bgm.stop()
		bgm.stream=null

func _exit_tree() -> void:
	stop_all()

func make_coin_collision() -> AudioStreamWAV:
	var stream:=AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=22050
	var bytes:=PackedByteArray()
	bytes.resize(int(0.105*22050)*2)
	var rng:=RandomNumberGenerator.new()
	rng.seed=388
	for i in range(bytes.size()/2):
		var t:=float(i)/22050
		var ring:=sin(TAU*1870*t)*exp(-t*65)*0.30+sin(TAU*3023*t)*exp(-t*90)*0.19+sin(TAU*4511*t)*exp(-t*115)*0.10
		var click:=rng.randf_range(-1,1)*exp(-t*210)*0.26
		bytes.encode_s16(i*2,int((ring+click)*minf(1,t*2200)*25000))
	stream.data=bytes
	return stream

func play_collision(strength: float) -> void:
	if not enabled:return
	var now:=Time.get_ticks_msec()
	if now-group_started>180:
		group_started=now
		collision_group=0
	collision_group+=1
	if collision_group>=4 and now-last_clatter>350:
		for voice in players:
			if not voice.playing:
				last_clatter=now
				voice.stream=sounds.clatter
				voice.volume_db=-12
				voice.pitch_scale=randf_range(0.9,1.05)
				voice.play()
				sound_played.emit("clatter")
				break
	# Short, quiet metal impacts; no event queue, no overlapping collision voices.
	if now-last_collision<160 or now-last_drop<100:return
	for player in players:
		if player.playing and player.stream==sounds.collision:return
	for player in players:
		if not player.playing:
			last_collision=now
			player.stream=sounds.collision
			player.volume_db=lerpf(-22,-14,clampf(strength,0,1))
			player.pitch_scale=randf_range(0.88,1.15)
			player.play()
			sound_played.emit("collision")
			return

func make_coin_clatter()->AudioStreamWAV:
	var stream:=AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=22050
	var bytes:=PackedByteArray()
	bytes.resize(int(0.30*22050)*2)
	var delays:Array=[0.0,0.007,0.016,0.031,0.052,0.069,0.091,0.117]
	var rng:=RandomNumberGenerator.new()
	rng.seed=5010
	for i in range(bytes.size()/2):
		var t:=float(i)/22050
		var value:=0.0
		for j in range(delays.size()):
			var age:float=t-delays[j]
			if age<0:continue
			var f:float=1320+j*247
			value+=(sin(TAU*f*age)*0.10+sin(TAU*f*1.677*age)*0.06)*exp(-age*46)*minf(1,age*2000)
			value+=rng.randf_range(-0.06,0.06)*exp(-age*100)
		bytes.encode_s16(i*2,int(clampf(value,-0.95,0.95)*29000))
	stream.data=bytes
	return stream
