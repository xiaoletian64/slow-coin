extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true;root.add_child(game);game.set_paused(false)
	game.machine.clear_coins();game.machine.pending.clear()
	for i in range(game.machine.CAPACITY):game.machine.spawn_coin(Vector3(0,0.1,0))
	var balance:int=game.wallet.balance
	for i in range(40):game.request_coin()
	check(not game.hud.drop_button.disabled and game.machine.pending.size()==40,"full tray still accepts more than 24 inputs")
	check(game.wallet.balance==balance-40,"each accepted input charged exactly once")
	var snapshot:Dictionary=game.machine.snapshot()
	check(game.machine.valid_snapshot(snapshot),"full physical tray plus independent queue is valid save")
	game.machine.restore(snapshot)
	game.machine._physics_process(0.14)
	check(game.machine.pending.size()==39 and game.machine.coins.get_child_count()==951,"1001st coin triggers removal of exactly fifty and input continues")
	for i in range(50):game.machine.spawn_coin(Vector3(0,0.1,0))
	check(game.machine.coins.get_child_count()==951,"next overflow removes exactly fifty again")
	check(game.harvest_total==0,"random removal does not count as front return")
	check(game.machine.valid_snapshot(game.machine.snapshot()),"trimmed tray remains valid for saving")
	check(game.wallet.balance==balance-40,"queue restore and release never charge again")
	game.feedback.stop_all();game.queue_free();await process_frame
	print("CONTINUOUS INPUT: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
