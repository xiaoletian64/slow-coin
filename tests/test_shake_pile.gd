extends SceneTree
var failures:=0
func _initialize()->void:call_deferred("run")
func run()->void:
	seed(1234)
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.ready_to_save=false
	game.set_paused(false)
	game.set_physics_process(false)
	var m=game.machine
	m.clear_coins()
	m.pending.clear()
	var exits:Array=[0]
	m.coin_exited.connect(func(_front,_at,_bonus):exits[0]+=1)
	for row in range(4):
		for col in range(8):
			m.spawn_pinboard_coin(Vector3(-1.645+col*0.47,3.5+row*0.47,m.BOARD_Z),Vector3.ZERO)
	for i in range(180):await physics_frame
	print("UPPER BEFORE SHAKE: ",m.shakeable_count())
	m.shake_clear()
	var saved:Dictionary=m.snapshot()
	m.restore(saved)
	for i in range(420):await physics_frame
	var remaining:int=m.shakeable_count()
	if m.coins.get_child_count()+int(exits[0])!=32:failures+=1;push_error("shake must conserve every coin through tray and exits")
	print("UPPER AFTER SHAKE: ",remaining)
	for peg in m.pinboard_pegs:
		if peg.collision_layer!=1 or not is_equal_approx(peg.position.z,m.BOARD_Z):
			failures+=1;push_error("pins must restore after clearing")
	if m.pinboard_pegs.size()!=7:failures+=1;push_error("sparser seven-pin layout")
	m.clear_coins()
	var prize=m.dispense_bonus(1,0)
	if prize.position.y-m.pinboard_pegs[0].position.y<1.6:failures+=1;push_error("outlet needs longer free fall")
	if remaining>0:failures+=1;push_error("one shake must release the whole upper pile")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	print("SHAKE PILE: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
