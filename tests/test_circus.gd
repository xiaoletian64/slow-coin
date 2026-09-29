extends SceneTree
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error(label)
func _initialize()->void:
	call_deferred("run")
func run()->void:
	var B=load("res://scripts/bonus.gd")
	for pair in [[0,0],[6000,58],[9000,388],[9800,2999],[9980,29999]]:
		var b=B.new()
		b.trigger(pair[0])
		var restored=B.new()
		check(restored.restore(b.to_dict()),"pending spin restores")
		restored.tick(3.0)
		check(restored.remaining==pair[1],"full physical coin debt")
		if restored.remaining>0:
			restored.tick(3.4)
			restored.consume_coin()
		var resumed=B.new()
		check(resumed.restore(restored.to_dict()) and resumed.remaining==restored.remaining,"remaining coins persist exactly")
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	await process_frame
	game.set_paused(false)
	game.machine.clear_coins()
	var bank:int=game.wallet.balance
	game.bonus.trigger(9000)
	game._physics_process(3.0)
	check(game.wallet.balance==bank,"388 prize does not directly credit wallet")
	check(game.bonus.remaining+game.bonus.emitted==388,"dispensing conserves all 388 coins")
	check(game.machine.pinboard_count()==game.bonus.emitted,"all dispensed prize coins enter the target path")
	game.machine.clear_coins()
	game.machine.spin_target.position.x=0
	var chain=game.machine.spawn_pinboard_coin(Vector3(0,2.1,-1.44),Vector3.ZERO,true)
	chain.previous_y=2.3
	game.machine.update_pinboard_coins()
	check(game.bonus.pending_spins==1,"prize coin crossing queues another spin while dispensing")
	game.machine.update_pinboard_coins()
	check(game.bonus.pending_spins==1,"same prize coin never awards two spins")
	var chained=B.new()
	check(chained.restore(game.bonus.to_dict()) and chained.pending_spins==1,"chain spin survives restart")
	chained.tick(3.4)
	check(chained.spinning and chained.pending_spins==0,"queued chain starts while payout remains")
	game.bonus.pending_spins=0
	game.machine.clear_coins()
	var c=game.machine.spawn_coin(Vector3(0,-0.4,3.3))
	c.bonus_coin=true
	game.machine.settle_exits()
	check(game.wallet.balance==bank+1,"reward coin pays only at front exit")
	check(game.bonus.pending_spins==0,"front exit never triggers spin")
	var side=game.machine.spawn_coin(Vector3(3.2,-0.4,1.5))
	game.machine.settle_exits()
	check(game.wallet.balance==bank+1,"side exit pays nothing")
	game.machine.clear_coins()
	game.bonus=B.new()
	game.machine.spin_target.position.x=0
	var hit=game.machine.spawn_coin(Vector3(0,2.1,-1.44))
	hit.set_pinboard(true)
	hit.previous_y=2.3
	game.machine.update_pinboard_coins()
	check(game.bonus.spinning,"upper moving target starts spin")
	game.machine.update_pinboard_coins()
	check(game.bonus.pending_spins==0,"one coin triggers once")
	game.machine.clear_coins()
	game.machine.aim_phase=0
	game.machine.aim_locked=true
	game.machine.update_aim()
	game.bonus= B.new()
	game.request_coin()
	for i in range(720):await physics_frame
	var stuck:=false
	for coin in game.machine.coins.get_children():
		if coin.in_pinboard and not coin.bonus_coin:
			print("STUCK INPUT: ",coin.position," guide=",coin.guide_distance)
			stuck=true
	check(not stuck,"locked center shot leaves pinboard within 12 seconds")
	game.machine.clear_coins()
	game.bonus=B.new()
	game.machine.phase=0
	game.machine.spin_target.position.x=0
	var crossing=game.machine.spawn_coin(Vector3(0,2.1,-1.44))
	crossing.set_pinboard(true)
	crossing.previous_y=2.3
	var snapshot:Dictionary=game.machine.snapshot()
	game.machine.restore(snapshot)
	game.machine.update_pinboard_coins()
	check(game.bonus.spinning,"save on target crossing preserves hit")
	var formal_snapshot:Dictionary=game.bonus.to_dict()
	game.switch_mode()
	var practice_bank:int=game.wallet.balance
	game.on_spin_hit()
	check(game.bonus.spinning,"practice also visibly spins on hit")
	game.on_coin_exited(true,Vector3.ZERO,true)
	check(game.wallet.balance==practice_bank,"practice rewards never credit wallet")
	game.switch_mode()
	check(game.bonus.to_dict()==formal_snapshot,"practice cannot overwrite formal prize debt")
	game.feedback.set_music_enabled(false)
	game.set_paused(true)
	game.set_paused(false)
	check(not game.feedback.get_node("BGM").playing,"BGM off remains off across pause")
	print("CIRCUS: ","PASS" if failures==0 else "FAIL")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit(0 if failures==0 else 1)
