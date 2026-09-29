extends SceneTree
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error(label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	for pair in [[8000,58],[9800,388],[9980,2999],[9998,29999]]:
		game.machine.clear_coins()
		game.bonus=load("res://scripts/bonus.gd").new()
		var balance:int=game.wallet.balance
		game.bonus.trigger(pair[0],0)
		game._physics_process(3.0)
		check(game.bonus.remaining==pair[1] and game.bonus.emitted==0,"story starts before physical payout")
		check(game.jackpot_fx.visible and game.jackpot_fx.amount==pair[1],"right story displayed")
		game._physics_process(1.0)
		check(game.machine.coins.get_child_count()==0,"no bonus coins during story")
		var saved:Dictionary=game.bonus.to_dict()
		var restored=load("res://scripts/bonus.gd").new()
		check(restored.restore(saved) and is_equal_approx(restored.presentation,2.4),"resume exact presentation progress")
		game.set_paused(true)
		game._physics_process(10)
		check(is_equal_approx(game.bonus.presentation,2.4),"pause freezes story")
		game.set_paused(false)
		game._physics_process(2.5)
		check((game.machine.tower.prize_pending and game.bonus.emitted==0) if pair[1]>=500 else (game.bonus.emitted==1 and game.bonus.remaining==pair[1]-1),"payout or tower begins after story")
		check(game.wallet.balance==balance,"story prize never directly credits wallet")
		game.on_spin_hit()
		check(game.bonus.spinning,"next draw starts during payout")
	game.jackpot_fx.celebrate(2999,2.4)
	check(game.jackpot_fx.screen_shake().length()>0,"cart story shakes the screen")
	game.jackpot_fx.celebrate(58,2.4)
	check(game.jackpot_fx.screen_shake()==Vector2.ZERO,"cat story does not quake")
	print("AWARD STORIES: ","PASS" if failures==0 else "FAIL")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
