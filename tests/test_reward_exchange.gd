extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	game.machine.clear_coins()
	var B=load("res://scripts/bonus.gd")
	game.bonus=B.new()
	game.bonus.trigger(9800);game.bonus.tick(3);game.bonus.tick(3.4)
	for i in range(187):game.bonus.consume_coin()
	game.refresh()
	check(game.bonus.remaining==201 and game.hud.settlement_button.visible,"201 pending coins exposes exchange")
	game.open_settlement()
	check(game.paused,"201 pending coins opens exchange")
	game.set_paused(false)
	game.bonus.consume_coin();game.refresh()
	game.open_settlement()
	check(not game.paused and not game.hud.settlement_button.visible,"200 pending coins does not expose or open exchange")
	game.set_paused(true)
	game.settle_pending_prizes()
	check(game.bonus.remaining==200,"200 pending coins cannot settle through direct action")
	game.set_paused(false)
	game.bonus=B.new()
	for roll in [8000,9800,8000,8000]:
		game.bonus.trigger(roll);game.bonus.tick(3);game.bonus.tick(3.4)
	for i in range(40):game.bonus.consume_coin()
	check(game.bonus.remaining==522,"multiple wins accumulate independently")
	check(game.machine.tower.request_prize_tower(),"cumulative prize can request tower")
	var saved:Dictionary=game.machine.snapshot()
	game.machine.restore(saved)
	game.machine.tower.tick(1.4)
	check(game.machine.coins.get_child_count()==50 and game.bonus.remaining==472,"tower creates fifty real coins and consumes debt across prize rows")
	saved=game.machine.snapshot()
	game.machine.restore(saved);game.machine.tower.tick(2)
	check(game.machine.coins.get_child_count()==50 and game.bonus.remaining==472,"revealed tower never grants twice")
	game.bonus.trigger(9998);game.bonus.tick(3);game.bonus.tick(3.4)
	game.bonus.trigger(0)
	game.bonus.pending_spins=3
	var owed:int=game.bonus.remaining
	var balance:int=game.wallet.balance
	var physical:int=game.machine.coins.get_child_count()
	game.open_settlement();game.settle_pending_prizes()
	check(game.bonus.remaining==0 and not game.bonus.spinning and game.bonus.pending_spins==0,"roulette resolves pending payout, current and queued draws")
	check(game.wallet.balance>=balance+int(game.bonus.last_settlement_pool*.01) and game.wallet.balance<=balance+int(game.bonus.last_settlement_pool*.9),"roulette pays within exact stated range")
	check(game.machine.coins.get_child_count()==physical,"roulette preserves physical tray")
	var after:int=game.wallet.balance
	game.settle_pending_prizes()
	check(game.wallet.balance==after,"repeat click cannot pay twice")
	var restored=B.new()
	check(restored.restore(game.bonus.to_dict()) and restored.remaining==0,"settled debt remains cleared after reload")
	var bank:int=game.wallet.balance
	game.on_coin_exited(true,Vector3.ZERO)
	check(game.harvest_total==1 and game.wallet.balance==bank+1,"collection count uses actual front exit only")
	game.on_coin_exited(false,Vector3.ZERO)
	check(game.harvest_total==1,"side loss never counts as collected")
	game.feedback.stop_all();game.queue_free()
	await process_frame
	print("TOWER / ROULETTE / COLLECTION: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
