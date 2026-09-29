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
	var m=game.machine
	m.clear_coins()
	check(m.swing_pivot.has_node("GuideRailLeft") and m.swing_pivot.has_node("GuideRailRight"),"two separate guide rods")
	check(m.swing_pivot.get_node("GuideRailLeft").mesh.height<1.0,"short physical guide")
	check(m.swing_pivot.has_node("MovingOutlet"),"outlet moves with guide assembly")
	var coin=m.spawn_guided_coin()
	check(coin.freeze and coin.guide_distance>=0,"same real token starts constrained in channel")
	m.update_guided_coins(0.15)
	var saved:Dictionary=m.snapshot()
	check(m.valid_snapshot(saved),"guided coin snapshot valid")
	m.restore(saved)
	coin=m.coins.get_child(0)
	check(coin.freeze and is_equal_approx(coin.guide_distance,saved.coins[0].guide_distance),"guided travel resumes after restore")
	check(m.shakeable_count()==0,"in-flight guide coin is not falsely treated as stuck board coin")
	for i in range(60):m.update_guided_coins(1.0/60)
	check(coin.guide_distance<0 and not coin.freeze and coin.collision_layer==1,"same token releases into physical pinboard")
	check(coin.linear_velocity.y<0,"released coin falls from the actual rail tip")
	m.aim_locked=true
	var angle:float=m.swing_pivot.rotation.z
	m._physics_process(0.2)
	check(m.swing_pivot.rotation.z==angle,"stop fixes both guide rods together")
	print("DOUBLE GUIDE: ","PASS" if failures==0 else "FAIL")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
