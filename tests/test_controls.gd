extends SceneTree
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error(label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	game.machine.clear_coins()
	game.clear_machine()
	check(game.machine.clearing==0,"empty upper board must not pause payout or claim coins are falling")
	game.toggle_test_target()
	check(game.practice and game.machine.test_target,"forced target only runs on practice board")
	game.machine.clear_coins()
	game.machine.pending.clear()
	game.request_coin()
	for i in range(150):await physics_frame
	check(game.bonus.spinning or game.bonus.elapsed==3.0,"test coin automatically crosses center hole and starts reels")
	game.toggle_test_target()
	game.machine.clear_coins()
	game.machine.seed_coins()
	var upper=game.machine.spawn_pinboard_coin(Vector3(0,2.78,-1.44),Vector3.ZERO)
	var lower=game.machine.spawn_coin(Vector3(2,0.06,2))
	lower.sleeping=true
	game.machine.shake_upper_coins()
	check(lower.sleeping and lower.linear_velocity==Vector3.ZERO,"shake never impulses lower tray coins")
	game.bonus=load("res://scripts/bonus.gd").new()
	game.bonus.trigger(9800,0)
	game.bonus.tick(3.0)
	game.clear_machine()
	var debt:int=game.bonus.remaining
	game._physics_process(0.1)
	check(game.bonus.remaining==debt,"clear pauses prize discharge without deleting debt")
	var snapshot:Dictionary=game.machine.snapshot()
	check(game.machine.valid_snapshot(snapshot),"clearing snapshot valid")
	game.machine.restore(snapshot)
	check(game.machine.clearing>0,"clear state resumes after restore")
	var exits: Array=[0]
	game.machine.coin_exited.connect(func(_f,_p,_b):exits[0]+=1)
	for i in range(350):await physics_frame
	check(not is_instance_valid(upper) or not upper.in_pinboard,"shake releases upper-board coin")
	check(game.bonus.remaining==debt if game.machine.clearing>0 else game.bonus.remaining+game.bonus.emitted==debt,"debt remains or resumes exact payout once upper board clears")
	game.switch_mode()
	check(not game.machine.test_target,"formal board never inherits guaranteed hits")
	game.wallet.balance=499
	game.submit_phrase("国安是冠军")
	check(game.wallet.balance==5499,"typed or IME phrase credits the same wallet rule")
	game.submit_phrase("山东驴")
	game.submit_phrase("跟丫死磕")
	check(game.wallet.balance==9491,"testing phrases available at normal balance")
	var shakes:Array=[0]
	var sensor=load("res://scripts/shake_detector.gd").new()
	sensor.shaken.connect(func():shakes[0]+=1)
	sensor.sample(Vector3(0,9.8,0),0.1)
	sensor.sample(Vector3(0,10,0),0.1)
	check(shakes[0]==0,"gentle motion does not clear")
	sensor.sample(Vector3(20,9.8,0),0.1)
	sensor.sample(Vector3(-20,9.8,0),0.1)
	check(shakes[0]==1,"back and forth shake triggers once")
	sensor.sample(Vector3(20,9.8,0),0.1)
	check(shakes[0]==1,"shake cooldown avoids repeated clears")
	sensor.free()
	print("TEST MODE / SHAKE: ","PASS" if failures==0 else "FAIL")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit(0 if failures==0 else 1)
