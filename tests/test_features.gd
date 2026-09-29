extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:
		failures+=1
		push_error(message)
func _initialize()->void:
	call_deferred("run")
func run()->void:
	var w=load("res://scripts/wallet.gd").new()
	if not w.has_method("buy_skin"):
		check(false,"Skin purchase with earned coins must be implemented")
		quit(1)
		return
	check(w.buy_skin("mint"),"purchase affordable skin")
	check(w.balance==8500 and w.owned_skins.has("mint"),"purchase permanently deducts price")
	check(w.buy_skin("mint") and w.balance==8500,"owned skin equip costs nothing")
	w.balance=1
	check(not w.buy_skin("sakura"),"unaffordable skin rejected")
	check(not w.buy_skin("unknown"),"unknown skin rejected")
	var w2=load("res://scripts/wallet.gd").new()
	check(w2.restore(w.to_dict()) and w2.owned_skins.has("mint"),"skin ownership persists")
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	for i in range(12):await physics_frame
	var angle:float=game.machine.aim_phase
	game.hud.aim_button.pressed.emit()
	for i in range(30):await physics_frame
	check(game.machine.aim_phase==angle,"stop locks exact swing position")
	game.hud.aim_button.pressed.emit()
	for i in range(20):await physics_frame
	check(game.machine.aim_phase!=angle,"resume swings again")
	var snapshot:Dictionary=game.machine.snapshot()
	game.machine.restore(snapshot)
	check(game.machine.aim_phase==snapshot.aim_phase,"swing restores")
	game.machine.clear_coins()
	game.on_spin_hit()
	check(game.bonus.spinning,"moving target triggers slot")
	var snapshot_bonus:Dictionary=game.bonus.to_dict()
	check(snapshot_bonus.reward in [0,58,388,2999,29999],"valid committed prize")
	var restored=load("res://scripts/bonus.gd").new()
	check(restored.restore(snapshot_bonus) and restored.reward==snapshot_bonus.reward,"no reroll on restore")
	game.bonus.spinning=false
	game.bonus.remaining=0
	var bank:int=game.wallet.balance
	var reward_coin=game.machine.spawn_coin(Vector3(0,-0.4,3.3))
	reward_coin.bonus_coin=true
	game.machine.settle_exits()
	check(not game.bonus.spinning,"front payout never triggers slot")
	check(game.wallet.balance==bank+1,"physical prize collected")
	game.switch_mode()
	game.on_spin_hit()
	check(game.bonus.spinning,"practice target runs an isolated slot")
	check(not game.inactive_bonus.spinning,"formal slot unchanged by practice")
	for mechanism in ["split","sweep","classic"]:
		game.change_mechanism(mechanism)
		for i in range(90):await physics_frame
		for coin in game.machine.coins.get_children():
			check(coin.position.is_finite(),"mechanism has finite physics")
	check(game.feedback.has_node("BGM") and game.feedback.get_node("BGM").stream!=null,"looping BGM exists")
	print("FEATURES: ","PASS" if failures==0 else "FAIL"," (",failures," failures)")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	quit(0 if failures==0 else 1)
