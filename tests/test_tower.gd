extends SceneTree
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error(label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(true)
	var m=game.machine
	m.clear_coins()
	var t=m.tower
	t.inputs=12
	t.wait_seconds=0
	t.tick(0.01)
	check(t.mist>0 and m.coins.get_child_count()==0,"mist starts before tower appears")
	var before:Dictionary=m.snapshot()
	m.restore(before)
	check(t.mist>0 and not t.revealed,"pre-reveal save resumes mist")
	var balance:int=game.wallet.balance
	t.tick(1.5)
	check(t.revealed and m.coins.get_child_count()==50,"50 real rigid-body tower coins appear")
	check(game.wallet.balance==balance,"tower doesn't directly credit wallet")
	var after:Dictionary=m.snapshot()
	m.restore(after)
	t.tick(0.1)
	check(m.coins.get_child_count()==50,"reveal restore never duplicates tower")
	for coin in m.coins.get_children():check(not coin.in_pinboard,"tower exclusively lower tray")
	m.shake_upper_coins()
	check(m.coins.get_child_count()==50,"shake doesn't clear lower tower")
	var coin=m.coins.get_child(0)
	coin.position=Vector3(0,-0.5,3.2)
	m.settle_exits()
	check(game.wallet.balance==balance+1,"tower front exit is credited normally")
	t.restore({})
	while m.coins.get_child_count()<m.CAPACITY-20:m.spawn_coin(Vector3(0,0,0))
	t.inputs=12
	t.wait_seconds=0
	t.tick(0.01)
	check(t.mist==0 and t.wait_seconds==10,"full tray defers instead of overlapping extra coins")
	m.clear_coins()
	m.phase=1.2
	m.configure_mechanism("sweep")
	check(t.find_site() and is_equal_approx(t.site.z,2.22),"sweep mechanism uses safe front site")
	check(m.valid_snapshot(m.snapshot()),"tower state validates")
	print("COIN TOWER: ","PASS" if failures==0 else "FAIL")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
