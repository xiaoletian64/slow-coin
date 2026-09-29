extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:call_deferred("run")
func run()->void:
	seed(1234)
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	var m=game.machine
	m.clear_coins()
	m.pending.clear()
	for row in range(4):
		for col in range(8):m.spawn_pinboard_coin(Vector3(-1.645+col*0.47,3.5+row*0.47,m.BOARD_Z),Vector3.ZERO)
	game.bonus.trigger(8000,0)
	game.clear_machine()
	for i in range(190):await physics_frame
	check(not game.bonus.spinning and game.bonus.reward==58,"shake cannot freeze current spin or lose committed reward")
	game.bonus.pending_spins=1
	var finished:=false
	for i in range(2400):
		await physics_frame
		if game.bonus.spinning:
			finished=true
			break
	check(finished,"single outlet clears 58-coin debt and next queued spin restarts automatically")
	print("SHAKE / JACKPOT RESUME: ","PASS" if failures==0 else "FAIL")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
