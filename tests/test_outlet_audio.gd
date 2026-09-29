extends SceneTree
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error(label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	game.machine.clear_coins()
	var heard:Array=[]
	game.feedback.sound_played.connect(func(kind):heard.append(kind))
	game.request_coin()
	game.on_coin_dropped()
	check(heard.is_empty(),"press and dispensing are silent")
	game.machine.pending.clear()
	check(game.machine.dispenser_flaps.size()==1,"one physical prize outlet")
	var first=game.machine.dispense_bonus(1,0)
	check(first!=null and first.position.x==0,"prize comes from central mouth")
	check(game.machine.dispense_bonus(3,1)==null,"occupied mouth cannot spawn overlapping coins")
	game.bonus.trigger(9000)
	game._physics_process(3.0)
	check(game.bonus.remaining==388,"blocked outlet preserves full prize debt")
	check(heard.is_empty(),"win and blocked dispenser make no ticks")
	check(game.bonus.presentation>0,"award story precedes payout")
	game._physics_process(3.4)
	check(game.bonus.remaining==388,"blocked mouth retains prize after story")
	game.machine.clear_coins()
	game.bonus.dispense_clock=0
	game._physics_process(0.01)
	check(game.bonus.remaining==387 and game.bonus.emitted==1,"single outlet consumes one owed coin")
	check(heard.is_empty(),"successful dispenser remains silent")
	game.on_coin_exited(true,Vector3(0,-0.4,3.3),true)
	check(heard==["drop"],"actual front fall plays drop sound")
	for i in range(12):game.on_coin_exited(true,Vector3(0,-0.4,3.3),true)
	check(heard==["drop","clatter"],"simultaneous falls merge into one clatter, not queued ticks")
	game.feedback.enabled=false
	game.feedback.last_drop=-1000
	game.on_coin_exited(true,Vector3(0,-0.4,3.3))
	check(heard.size()==2,"sound off remains silent")
	print("SINGLE OUTLET / DROP AUDIO: ","PASS" if failures==0 else "FAIL")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit(0 if failures==0 else 1)
