extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:call_deferred("run")
func run()->void:
	var W=load("res://scripts/wallet.gd")
	var w=W.new()
	check(w.TITLES.size()==24 and w.DAILY_TITLES.size()==8,"permanent and daily title catalogs")
	check(not w.equip_title(101),"locked daily title cannot equip")
	for i in range(10):w.spend(false)
	check(w.equip_title(101),"daily ten-input title unlocks")
	var saved:Dictionary=w.to_dict()
	var restored=W.new()
	check(restored.restore(saved) and restored.equipped_title==101,"daily title survives same-day reload")
	saved.daily_date="2000-01-01"
	check(restored.restore(saved) and restored.equipped_title==0 and restored.daily_records.is_empty(),"new day resets only daily title")
	check(restored.has_title(1) and restored.inserted==10,"permanent progress survives daily reset")
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	game.request_coin();game.request_coin()
	var bank:int=game.wallet.balance
	game.bonus.trigger(9000);game.bonus.tick(3)
	game.bonus.pending_spins=2
	game.set_paused(true);game.restart_round()
	check(game.wallet.balance==bank+2 and game.machine.pending.is_empty(),"restart refunds paid unspawned inputs")
	check(game.bonus.remaining==388 and game.bonus.pending_spins==2,"restart keeps earned and queued prizes")
	check(game.machine.coins.get_child_count()>100 and not game.paused,"restart seeds playable tray")
	check(game.wallet.has_title(22),"restart title unlocks")
	game.feedback.stop_all();game.queue_free()
	await process_frame
	print("DAILY TITLES / RESTART: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
