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
	var m=game.machine
	m.clear_coins()
	m.pending.clear()
	m.tower.site=Vector3(0,0.06,2.22)
	m.tower.spawn_tower()
	var layer_counts:Dictionary={}
	for coin in m.coins.get_children():
		var layer:=roundi((coin.position.y-0.06)/0.098)
		layer_counts[layer]=layer_counts.get(layer,0)+1
	check(layer_counts.size()==10,"ten layers")
	for count in layer_counts.values():check(count==5,"five coins in each layer")
	for i in range(90):await physics_frame
	var highest:=0.0
	for coin in m.coins.get_children():highest=maxf(highest,coin.position.y)
	check(highest>0.7,"tower stands tall under real physics before edge push")
	var before:int=game.wallet.balance
	for coin in m.coins.get_children():coin.apply_central_impulse(Vector3(0,0,0.10))
	for i in range(180):await physics_frame
	check(game.wallet.balance>before,"pushed tower collapses and actual front falls pay out")
	print("TOWER PHYSICS: ","PASS" if failures==0 else "FAIL", " stable height=",highest," returned=",game.wallet.balance-before)
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
