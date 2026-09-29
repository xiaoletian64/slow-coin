extends SceneTree
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error(label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(true)
	var wallet=game.wallet
	var original:Dictionary=wallet.to_dict()
	wallet.balance=12000
	check(wallet.buy_skin("clown_deluxe") and wallet.balance==0,"12000 permanent unlock")
	check(wallet.buy_skin("clown_deluxe") and wallet.balance==0,"re-equip never charges again")
	var restored=load("res://scripts/wallet.gd").new()
	check(restored.restore(wallet.to_dict()) and restored.equipped_skin=="clown_deluxe","owned premium survives restart")
	check(wallet.restore(original),"old save accepted")
	wallet.balance=0
	for mechanism in ["classic","split","sweep"]:
		game.machine.configure_mechanism(mechanism)
		var coin=game.machine.coins.get_child(0)
		var id:int=coin.get_instance_id()
		var pose:Transform3D=coin.transform
		coin.linear_velocity=Vector3(0.1,0.2,0.3)
		coin.angular_velocity=Vector3(0.3,0.2,0.1)
		var shape=coin.get_child(0).shape
		var mass:float=coin.mass
		game.bonus.trigger(9800)
		game.bonus.tick(3)
		var debt:int=game.bonus.remaining
		var pending:int=game.bonus.pending_spins
		game.preview_skin("clown_deluxe")
		check(game.machine.premium.visible and game.hud.premium_layout,"preview works without enough coins")
		check(game.wallet.equipped_skin==original.equipped_skin,"preview doesn't equip wallet")
		check(game.make_save().wallet.equipped_skin==original.equipped_skin,"save during preview keeps purchased skin")
		game.close_skin_preview()
		check(not game.machine.premium.visible and not game.hud.premium_layout,"preview close restores old skin")
		check(coin.get_instance_id()==id and coin.transform==pose and coin.get_child(0).shape==shape and coin.mass==mass,"skin doesn't recreate or reshape physics")
		check(coin.linear_velocity==Vector3(0.1,0.2,0.3) and coin.angular_velocity==Vector3(0.3,0.2,0.1),"skin keeps velocities")
		check(game.bonus.remaining==debt and game.bonus.pending_spins==pending,"skin preserves pending payouts")
		game.preview_skin("clown_deluxe")
		game.set_paused(false)
		check(game.preview_skin_id.is_empty() and not game.machine.premium.visible,"resume exits preview")
		game.set_paused(true)
	var bad:Dictionary=wallet.to_dict()
	bad.owned_skins=["classic","classic"]
	check(not restored.restore(bad),"duplicate skin ids rejected")
	print("PREMIUM SKIN: ","PASS" if failures==0 else "FAIL")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
