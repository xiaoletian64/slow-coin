extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	for i in range(90): await physics_frame
	for i in range(8): game.request_coin()
	var state:Dictionary=game.make_save()
	var owed: int=state.boards.classic.coins.size()+state.boards.classic.queue.size()
	check(state.boards.classic.queue.size()==8,"queue paid before exit")
	var cash:int=game.wallet.balance
	game.machine.phase=4.0
	game.machine.update_pusher()
	game.machine.restore(state.boards.classic)
	for i in range(state.boards.classic.coins.size()):
		check(game.machine.coins.get_child(i).linear_velocity.is_equal_approx(game.machine.Coin.unvec(state.boards.classic.coins[i].v)),"restore preserves saved velocity before physics")
	game.wallet.restore(state.wallet)
	var side_exits:Array=[0]
	game.machine.coin_exited.connect(func(front,_p,_b):
		if not front:side_exits[0]+=1)
	for i in range(190): await physics_frame
	check(game.wallet.inserted==8,"resume never recharges paid queue")
	check(game.machine.pending.is_empty(),"restored queue dispensed")
	check(game.machine.coins.get_child_count()+game.machine.pending.size()+game.wallet.collected-int(state.wallet.collected)+side_exits[0]==owed,"restore preserves physical and paid coins")
	for c in game.machine.coins.get_children():
		check(c.position.is_finite() and absf(c.position.z)<5 and c.linear_velocity.length()<12,"restore does not fling coins")
	var post:Dictionary=game.make_save()
	game.machine.restore(post.boards.classic)
	game.wallet.restore(post.wallet)
	check(game.machine.pending.is_empty(),"dispensed coin is not queued twice")
	game.machine.clear_coins()
	game.machine.spawn_coin(Vector3(0,-0.4,3.3))
	game.machine.settle_exits()
	var settled:Dictionary=game.make_save()
	var settled_cash:int=game.wallet.balance
	game.machine.restore(settled.boards.classic)
	game.wallet.restore(settled.wallet)
	game.machine.settle_exits()
	check(game.wallet.balance==settled_cash,"settled payout not duplicated on restart")
	# Last-day stamp survives a process restart.
	check(game.wallet.claim_daily(game.wallet.last_daily)==0,"daily grant persists")
	game.set_paused(true)
	var save:Dictionary=game.make_save()
	check(save.wallet.balance==game.wallet.balance,"background save captures wallet")
	print("RESTORE: ","PASS" if failures==0 else "FAIL"," (",failures," failures)")
	game.feedback.stop_all()
	game.queue_free()
	paused=false
	await process_frame
	await create_timer(0.1).timeout
	quit(0 if failures==0 else 1)
