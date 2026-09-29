extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:call_deferred("run")
func run()->void:
	var B=load("res://scripts/rainbow_ball.gd")
	var hits:=0
	for i in range(10000):
		if B.wins(i):hits+=1
	check(hits==100,"exactly one percent of input rolls trigger event")
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true;root.add_child(game);game.machine.set_physics_process(false)
	game.machine.clear_coins()
	var event=game.machine.rainbow
	check(not event.input_accepted(100) and event.age<0,"miss does not start animation")
	check(event.input_accepted(99) and event.age==0,"hit starts animation")
	var coin=game.machine.spawn_coin(event.site+Vector3(0.2,-0.4,0))
	var upper=game.machine.spawn_pinboard_coin(Vector3(0,3,-1.44),Vector3.ZERO)
	var balance:int=game.wallet.balance
	event.tick(0.7)
	var save:Dictionary=game.machine.snapshot()
	check(game.machine.valid_snapshot(save),"animation state valid for save")
	game.machine.restore(save);event=game.machine.rainbow
	check(is_equal_approx(event.age,0.7) and not event.hit,"restore continues pre-impact animation")
	coin=game.machine.coins.get_child(0);upper=game.machine.coins.get_child(1)
	upper.freeze=true
	await physics_frame
	await process_frame
	event.tick(0.61)
	await physics_frame
	await process_frame
	check(event.hit and coin.linear_velocity.length()>0,"impact physically moves tray coin")
	check(upper.linear_velocity==Vector3.ZERO,"impact does not move upper board coin")
	check(game.wallet.balance==balance and game.harvest_total==0,"impact never directly credits wallet")
	var after:Dictionary=game.machine.snapshot()
	game.machine.restore(after)
	coin=game.machine.coins.get_child(0)
	var velocity:Vector3=coin.linear_velocity
	event.tick(0.1)
	check(coin.linear_velocity.is_equal_approx(velocity),"restoring after impact never applies impulse twice")
	event.input_accepted(0)
	check(event.queued==1,"additional event queues without replacing active animation")
	event.tick(3);event.tick(0.01)
	check(event.age==0 and event.queued==0,"queued event starts after previous finishes")
	game.feedback.stop_all();game.queue_free();await process_frame
	print("RAINBOW BALL: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
