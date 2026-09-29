extends SceneTree
var failures:=0
func _initialize()->void:call_deferred("run")
func run()->void:
	Engine.time_scale=8
	Engine.physics_ticks_per_second=480
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/full-tray-payout.json"))
	game.machine.restore(data.boards.classic)
	game.bonus.restore(data.bonus)
	game._physics_process(0.5)
	if game.bonus.remaining!=16:failures+=1;push_error("prize may use the reserved twelve positions")
	var chained:=false
	for i in range(3600):
		await physics_frame
		if game.bonus.emitted>=58:
			chained=true
			break
	if not chained:failures+=1;push_error("228-coin saved tray must emit all 17 remaining coins while queued draws run")
	game.machine.restore(data.boards.classic)
	game.bonus=load("res://scripts/bonus.gd").new()
	game.bonus.trigger(9800)
	var large_finished:=false
	for i in range(12000):
		await physics_frame
		if game.bonus.emitted>=388:
			large_finished=true
			break
	if not large_finished:failures+=1;push_error("388 prize must complete on previously full tray without extra input")
	print("SAVED FULL TRAY PAYOUT: ","PASS" if failures==0 else "FAIL", " count=",game.machine.coins.get_child_count()," owed=",game.bonus.remaining," emitted=",game.bonus.emitted," upper=",game.machine.pinboard_count()," tower_pending=",game.machine.tower.prize_pending)
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
