extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	var accepted:=0
	var rejected:=0
	var max_count:=0
	var max_ms:=0.0
	var started:=Time.get_ticks_usec()
	for i in range(7200):
		if i%15==0:
			game.machine.lane = [-2.05,0.0,2.05][(i/15)%3]
			var before: int = game.wallet.inserted
			game.request_coin()
			if game.wallet.inserted>before: accepted+=1
			else: rejected+=1
		await physics_frame
		max_count=maxi(max_count,game.machine.coins.get_child_count()+game.machine.pending.size())
		for c in game.machine.coins.get_children():
			if not c.position.is_finite() or absf(c.position.x)>4 or absf(c.position.z)>5 or c.position.y>6.5:
				push_error("Coin escaped: "+str(c.position))
				quit(1)
				return
	var pin_count:=0
	for coin in game.machine.coins.get_children():
		if coin.in_pinboard:pin_count+=1
	print("PINBOARD remaining: ",pin_count," payout debt: ",game.bonus.remaining)
	var full_count: int=game.machine.coins.get_child_count()
	for i in range(900):await physics_frame
	print("Idle recovery: ",full_count," -> ",game.machine.coins.get_child_count()," capacity ready=",game.machine.accepts_coin())
	var recovered:bool=game.machine.accepts_coin()
	var seconds:float=(Time.get_ticks_usec()-started)/1000000.0
	print("ENDURANCE 120 simulated seconds: inserted=",accepted," rejected=",rejected," front=",game.wallet.collected," max_count=",max_count," final_count=",game.machine.coins.get_child_count()," elapsed=",seconds)
	var bad:bool=game.wallet.collected<20 or accepted<200 or max_count>game.machine.CAPACITY or not recovered
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	if bad:
		push_error("Machine must remain playable with genuine front payouts")
		quit(1)
	else:
		quit(0)
