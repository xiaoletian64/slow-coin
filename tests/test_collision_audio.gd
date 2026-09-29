extends SceneTree
var failures:=0
var hits:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error(label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var world:=Node3D.new()
	root.add_child(world)
	var C=load("res://scripts/coin.gd")
	var fixed=C.new()
	fixed.freeze=true
	world.add_child(fixed)
	var moving=C.new()
	world.add_child(moving)
	moving.position=Vector3(0,1,0)
	fixed.metal_hit.connect(func(_strength):hits+=1)
	moving.metal_hit.connect(func(_strength):hits+=1)
	for i in range(90):await physics_frame
	check(hits>=1,"real falling coin against coin emits collision")
	var settled_hits:=hits
	for i in range(90):await physics_frame
	check(hits==settled_hits,"resting coins make no new impact sounds")
	var floor_body:=StaticBody3D.new()
	world.add_child(floor_body)
	floor_body.position=Vector3(3,-0.1,0)
	var floor_shape:=CollisionShape3D.new()
	var box:=BoxShape3D.new()
	box.size=Vector3(2,0.2,2)
	floor_shape.shape=box
	floor_body.add_child(floor_shape)
	var landing=C.new()
	world.add_child(landing)
	landing.position=Vector3(3,1.2,0)
	var landings:Array=[0]
	landing.surface_hit.connect(func():landings[0]+=1)
	for i in range(90):await physics_frame
	check(landings[0]>=1,"actual fall onto empty tray emits landing sound")
	var settled_landings:int=landings[0]
	for i in range(90):await physics_frame
	check(landings[0]==settled_landings,"resting tray contact remains silent")
	var feedback=load("res://scripts/feedback.gd").new()
	root.add_child(feedback)
	feedback.set_music_enabled(false)
	var heard:Array=[]
	feedback.sound_played.connect(func(kind):heard.append(kind))
	feedback.play_collision(0.7)
	for i in range(20):feedback.play_collision(1.0)
	check(heard==["collision","clatter"],"dense collision burst makes one clatter without queued ticks")
	feedback.enabled=false
	feedback.last_collision=-1000
	feedback.play_collision(1.0)
	check(heard.size()==2,"muted collision stays silent")
	print("COLLISION AUDIO: ","PASS" if failures==0 else "FAIL", " physical hits=",hits)
	feedback.stop_all()
	feedback.queue_free()
	world.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
