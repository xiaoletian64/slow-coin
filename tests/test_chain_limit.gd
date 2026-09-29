extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:call_deferred("run")
func run()->void:
	var B=load("res://scripts/bonus.gd")
	var b=B.new()
	b.trigger(9999)
	check(b.trigger() and b.trigger() and not b.trigger(),"only two followups accepted while initial prize spins")
	check(b.pending_spins==2,"queue cap visible")
	b.tick(3);b.tick(3.4)
	check(b.chain_used==1 and b.pending_spins==1,"first queued draw consumes one slot")
	check(not b.trigger(),"running plus queued draw reserves both slots")
	b.tick(3);b.tick(3.4)
	check(b.chain_used==2 and b.pending_spins==0,"second queued draw consumes final slot")
	check(not b.trigger(),"second win cannot extend chain")
	var restored=B.new()
	check(restored.restore(b.to_dict()) and restored.chain_used==2 and not restored.trigger(),"restart does not reset cap")
	var old=b.to_dict();old.erase("chain_used");old.pending_spins=20;old.pending_reduced=[]
	var migrated=B.new()
	check(migrated.restore(old) and migrated.pending_spins<=1 and migrated.reward==b.reward,"legacy excess queue trimmed, committed result preserved")
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true;root.add_child(game)
	for state in ["spinning","presentation","remaining","idle"]:
		var ui=B.new();ui.pending_spins=2
		ui.spinning=state=="spinning"
		ui.presentation=1 if state=="presentation" else 0
		ui.remaining=58 if state=="remaining" else 0
		game.hud.update_slot(ui,false)
		check("待抽 2 次" in game.hud.slot_status.text and "待抽 2 次" in game.hud.compact_slot_status.text,"count remains visible during "+state)
	game.feedback.stop_all();game.queue_free();await process_frame
	print("CHAIN LIMIT / COUNTER: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
